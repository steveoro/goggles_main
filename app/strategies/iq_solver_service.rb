# frozen_string_literal: true

# = IqSolverService
#
#   - author......: Steve A.
#   - last updated: 20210610
#
# Tries to solve in a single pass a specified ImportQueue row,
# updating in #solved_data the JSON representation of what has actually
# been solved.
#
# When the target entity can be solved completely, the row will be
# marked as "done" and it will be erased on the next subsequent pass.
#
class IqSolverService
  # Runs the solver task. Does nothing if the specified row is not an import queue row.
  #
  # 1. Deletes the row if it's been already solved (may happen on concurrent runs)
  # 2. Tries to solve the target entity
  # 3. Updates the row with what was actually solved (as IDs)
  #
  # == Params:
  # - import_queue_row: the valid GogglesDb::ImportQueue instance to be processed
  #
  # == Returns:
  # - +nil+ on no change or no processing
  #
  def call(import_queue_row)
    return unless import_queue_row.instance_of?(GogglesDb::ImportQueue)
    return if import_queue_row.done?

    # Use the helper methods from the decorator:
    iq_row = GogglesDb::ImportQueueDecorator.decorate(import_queue_row)
    # Get the latest version of the requested root key:
    latest_request = iq_row.solved.presence || iq_row.req
    return if latest_request.blank?

    # Solve the row:
    solver = Solver::Factory.for(iq_row.target_entity, latest_request)
    solver.solve!

    # Update the solved bindings in solved data:
    iq_row.done = solver.solved?
    iq_row.process_runs = iq_row.process_runs + 1
    iq_row.solved_data = prepare_solved_data_hash(iq_row, solver).to_json
    iq_row.save!
  end

  private

  # Updates the request fields by merging the original request with the solved bindings
  # and keeping any already set fields.
  # Returns the solved request data Hash given the decorated IQ row and its solver
  # (already run).
  def prepare_solved_data_hash(iq_decorated_row, solver)
    iq_decorated_row.solved
                    .merge(iq_decorated_row.req)
                    .merge(
                      iq_decorated_row.root_key => iq_decorated_row.req.fetch(iq_decorated_row.root_key, {})
                                                                   .merge(solver.bindings_solved)
                    )
  end
end
