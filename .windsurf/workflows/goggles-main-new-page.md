---
description: Add a new public-facing page to goggles_main — controller, HAML view, component, Datagrid, Stimulus, route, and specs
auto_execution_mode: 2
---

# New Page in goggles_main

Use this skill when adding a new public-facing page to the `goggles_main` frontend application.

## Background

- Path: `/home/steve/Projects/goggles_main/`
- Stack: Rails 6.1, HAML views, ViewComponent, Datagrid, Stimulus, Devise auth
- 21 controllers, 92 components, 140 views, 6 grids
- Routes in `config/routes.rb`
- GogglesDb engine mounted at `/`

## Step-by-step Procedure

### 1. Define the Route

Edit `config/routes.rb`:

```ruby
# Simple page:
get '<resource>/action_name'

# RESTful resource:
resources :<resource_name>, only: [:index, :show] do
  # nested routes if needed
end
```

Existing route patterns include both explicit `get` declarations and RESTful resources. Check the file for the style that fits.

### 2. Create the Controller

Create `app/controllers/<resource>_controller.rb`:

```ruby
# frozen_string_literal: true

# = <Resource>Controller
#
class <Resource>Controller < ApplicationController
  # Add authentication requirement if needed:
  before_action :authenticate_user!, only: %i[protected_action]

  # GET /<resource>/:id
  def show
    @record = GogglesDb::<Model>.find_by(id: params[:id])
    if @record.nil?
      flash[:warning] = I18n.t('search_view.errors.invalid_request')
      redirect_to(root_path) && return
    end
  end

  # GET /<resource>
  def index
    # Use Datagrid for tabular pages or direct queries:
    @grid = <Resource>Grid.new(grid_params) do |scope|
      scope.page(params[:page]).per(20)
    end
  end

  private

  def grid_params
    params.fetch(:<resource>_grid, {}).permit!
  end
end
```

Conventions:

- Inherit from `ApplicationController`
- Use `before_action :authenticate_user!` for protected pages
- Redirect with flash on invalid requests (follow `SwimmersController` pattern)
- Use `GogglesDb::` prefix for all model references
- API calls via `APIProxy` for data not available through the engine directly

### 3. Create the View

Create `app/views/<resource>/<action>.html.haml`:

```haml
- content_for(:title, t('<resource>.title'))

%section
  .container
    .row
      .col-12
        %h4.mt-3= t('<resource>.title')

    - if @record.present?
      .row
        .col-12
          = render(<Resource>::DetailComponent.new(record: @record))
```

Conventions:

- Use `content_for(:title)` for page title
- Use Bootstrap grid classes (`container`, `row`, `col-*`)
- Use i18n for all user-facing text
- Render ViewComponents for reusable UI blocks

### 4. Create ViewComponents (if needed)

See the `/goggles-main-component` skill for the full pattern.

Components go in `app/components/<resource>/` with a `.rb` class and `.html.haml` template.

### 5. Create a Datagrid (if tabular)

For pages with filterable/sortable tables, create `app/grids/<resource>_grid.rb`:

```ruby
# frozen_string_literal: true

class <Resource>Grid
  include Datagrid

  scope { GogglesDb::<Model>.all }

  filter(:name, :string) { |value| where('name LIKE ?', "%#{value}%") }
  filter(:season_id, :integer)

  column(:id)
  column(:name)
  column(:description)
  # Add more columns as needed
end
```

6 existing grids in `app/grids/` as reference.

### 6. Add Stimulus Controller (if interactive)

Create `app/javascript/controllers/<resource>_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  connect() {
    // initialization
  }

  // action methods...
}
```

Wire it in the HAML view:

```haml
%div{ data: { controller: '<resource>' } }
  %button{ data: { action: 'click-><resource>#doSomething' } }
```

### 7. Add i18n Keys

Add locale keys in `config/locales/`:

```yaml
en:
  <resource>:
    title: "Page Title"
    # ... more keys
it:
  <resource>:
    title: "Titolo Pagina"
    # ...
```

### 8. Write Specs

#### Controller Spec

Create `spec/controllers/<resource>_controller_spec.rb` (or `spec/requests/`).

#### View Spec

Create `spec/views/<resource>/<action>.html.haml_spec.rb`.

#### Cucumber Feature (for integration)

Create `features/<resource>.feature`:

```gherkin
Feature: <Resource> page
  Scenario: Viewing the <resource> page
    Given I am a logged-in user
    When I visit the <resource> page
    Then I should see the <resource> content
```

### 9. Run Tests

```bash
cd /home/steve/Projects/goggles_main
bundle exec rspec spec/controllers/<resource>_controller_spec.rb
bundle exec cucumber features/<resource>.feature
```
