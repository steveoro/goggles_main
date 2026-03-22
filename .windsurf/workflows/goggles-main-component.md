---
description: Create or modify a ViewComponent in goggles_main — pattern, HAML template, decorator usage, i18n, and specs
auto_execution_mode: 2
---

# ViewComponent in goggles_main

Use this skill when creating or modifying a ViewComponent in `goggles_main`. Components are the primary way to build reusable UI blocks.

## Background

- Components live in `/home/steve/Projects/goggles_main/app/components/`
- 92 components organized by domain (e.g. `mir/`, `meeting/`, `laps/`, `combo_box/`)
- Each component has a `.rb` class and a `.html.haml` template (co-located)
- Uses the `view_component` gem

## Component Structure

```text
app/components/
├── <domain>/
│   ├── <name>_component.rb           # Ruby class
│   └── <name>_component.html.haml    # HAML template
├── flash_alert_component.rb           # Top-level components (no domain folder)
└── flash_alert_component.html.haml
```

## Step-by-step Procedure

### 1. Create the Component Class

Create `app/components/<domain>/<name>_component.rb`:

```ruby
# frozen_string_literal: true

module <Domain>
  #
  # = <Domain>::<Name>Component
  #
  #   - version:  7-0.x.xx
  #   - author:   Steve A.
  #
  class <Name>Component < ViewComponent::Base
    # Creates a new ViewComponent.
    #
    # == Params:
    # - :record => [required] the GogglesDb::<Model> instance to display
    # - :option => [optional] description (default: value)
    #
    def initialize(options = {})
      super
      @record = options[:record]
      @option = options[:option] || default_value
    end

    # Skips rendering unless the required data is present
    def render?
      @record.present?
    end

    protected

    # Memoized decorated/computed values:
    def display_label
      @display_label ||= @record.decorate.display_label
    end
  end
end
```

Conventions from `MIR::TableRowComponent` and others:

- Accept an `options` hash in the constructor (not positional args)
- Always call `super` in `initialize`
- Override `render?` to skip rendering when data is missing
- Use `protected` methods for memoized computed values
- Use `&.` safe navigation for optional associations
- Memoize with `||=` to avoid repeated queries

### 2. Create the HAML Template

Create `app/components/<domain>/<name>_component.html.haml`:

```haml
%div.component-wrapper
  .row
    .col-auto
      = display_label
    .col
      = @record.some_attribute
```

Conventions:

- Use Bootstrap classes for layout
- Access component methods directly (no `@` prefix for protected methods)
- Use `@` for instance variables set in the constructor
- Use i18n: `= t('.label_key')` (component-scoped) or `= t('full.key.path')`
- Use decorators for display logic: `@record.decorate.display_label`
- Render sub-components: `= render(<SubDomain>::<SubComponent>.new(...))`

### 3. Render the Component

From a view or another component:

```haml
= render(<Domain>::<Name>Component.new(record: @record, option: value))
```

Or using the shorthand:

```ruby
render <Domain>::<Name>Component.new(record: @record)
```

### 4. Common Patterns

#### Using GogglesDb Decorators

```ruby
# In the component class:
def swimmer_label
  @swimmer_label ||= @record.swimmer&.decorate&.display_label
end
```

#### Conditional Rendering

```ruby
def render?
  @record.class.ancestors.include?(GogglesDb::AbstractResult) && @record.swimmer_id.to_i.present?
end
```

#### Preloading Associations

```ruby
def initialize(options = {})
  super
  @record = options[:record]
  # Move to memory to prevent N+1:
  @laps = @record.laps.to_a.sort_by(&:length_in_meters) if @record.respond_to?(:laps)
end
```

### 5. Write Component Specs

Create `spec/components/<domain>/<name>_component_spec.rb`:

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe <Domain>::<Name>Component, type: :component do
  let(:record) { create(:<model>) }

  context 'with a valid record' do
    subject { render_inline(described_class.new(record: record)) }

    it 'renders the component' do
      expect(subject.css('.component-wrapper')).to be_present
    end

    it 'displays the record label' do
      expect(subject.text).to include(record.decorate.display_label)
    end
  end

  context 'with a nil record' do
    subject { render_inline(described_class.new(record: nil)) }

    it 'does not render' do
      expect(subject.text).to be_blank
    end
  end
end
```

### 6. Run Tests

```bash
cd /home/steve/Projects/goggles_main
bundle exec rspec spec/components/<domain>/<name>_component_spec.rb
```

## Existing Component Domains

| Domain | Count | Examples |
| --- | --- | --- |
| `mir/` | Table rows for individual results | `TableRowComponent` |
| `mrr/` | Table rows for relay results | `TableRowComponent` |
| `meeting/` | Meeting display blocks | header, stats, team scores |
| `mevent/` | Meeting event sections | event header, results table |
| `mprg/` | Meeting program sections | category rows |
| `laps/` | Lap display | table rows, edit forms |
| `relay_laps/` | Relay lap display | fraction rows |
| `combo_box/` | Select2-style dropdowns | DbLookup, various entity selectors |
| `grid/` | Datagrid wrappers | filter, table, pagination |
| `icon/` | Icon components | Various FA icons |
| `switch/` | Toggle switches | Stimulus-wired toggles |
| `title/` | Page title blocks | With breadcrumbs |
| `wizard_form/` | Multi-step forms | Chrono wizard |
| `footer/` | Page footer | Site footer |
| `issues/` | Issue report forms | Type-specific forms |

## goggles_admin2 Components

`goggles_admin2` has 65 components following the same pattern in `/home/steve/Projects/goggles_admin2/app/components/`. The same skill applies there.
