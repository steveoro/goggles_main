# frozen_string_literal: true

# = IssuesGrid
#
# DataGrid showing filtered Issue rows for the current_user's "My reports" page.
#
# The base scope must be always filtered by:
# - current_user (with #for_user())
#
class IssuesGrid < BaseGrid
  # Returns the default scope for the grid. (#assets is the filtered version of it)
  scope do
    GogglesDb::Issue.includes(:user).joins(:user)
  end

  filter(:code, :enum, header: I18n.t('issues.grid.params.code'),
                       select: proc {
                                 [
                                   [I18n.t('issues.label_0'), '0'],
                                   [I18n.t('issues.label_1a'), '1a'],
                                   [I18n.t('issues.label_1b'), '1b'],
                                   [I18n.t('issues.label_1b1'), '1b1'],
                                   [I18n.t('issues.label_2b1'), '2b1'],
                                   [I18n.t('issues.label_3b'), '3b'],
                                   [I18n.t('issues.label_3c'), '3c'],
                                   [I18n.t('issues.label_4'), '4']
                                 ]
                               }) do |value, scope|
    scope.where(code: value)
  end

  filter(:status, :enum, header: I18n.t('issues.grid.params.status'),
                         select: proc {
                                   [
                                     [I18n.t('issues.status_0'), 0],
                                     [I18n.t('issues.status_1'), 1],
                                     [I18n.t('issues.status_2'), 2],
                                     [I18n.t('issues.status_3'), 3],
                                     [I18n.t('issues.status_4'), 4],
                                     [I18n.t('issues.status_5'), 5],
                                     [I18n.t('issues.status_6'), 6]
                                   ]
                                 }) do |value, scope|
    scope.where(status: value)
  end

  # Customizes row background color
  def row_class(row)
    return 'bg-light-cyan2' if row&.priority == 1
    return 'bg-light-yellow' if row&.priority == 2

    'bg-light-red2' if row&.priority == 3
  end
  #-- -------------------------------------------------------------------------
  #++

  # rubocop:disable Rails/OutputSafety
  column(:code, header: I18n.t('issues.grid.params.code'), html: true, mandatory: true, order: :code) do |asset|
    asset.decorate.code_flag << '&nbsp;'.html_safe << asset.decorate.long_label <<
      "<br/><small><code class='text-secondary'>#{asset.req}</code></small>".html_safe
  end
  # rubocop:enable Rails/OutputSafety

  column(:priority, header: I18n.t('issues.grid.params.priority'), html: true, mandatory: true, order: :priority) do |asset|
    asset.decorate.priority_flag
  end

  column(:status, header: I18n.t('issues.grid.params.status'), html: true, mandatory: true, order: :status) do |asset|
    tag.small(class: 'text-secondary') do
      asset.decorate.state_flag << '<br/>'.html_safe << I18n.t("issues.status_#{asset.status}").html_safe
    end
  end

  column(:destroy, header: '', html: true, order: false, mandatory: true) do |asset|
    button_to(issues_destroy_path(id: asset.id), id: "frm-delete-row-#{asset.id}", method: :delete,
                                                 class: 'btn btn-sm btn-outline-danger my-1',
                                                 data: { confirm: t('issues.grid.confirm_delete', label: asset.decorate.label) }) do
      tag.i(class: 'fa fa-trash-o')
    end
  end
end
