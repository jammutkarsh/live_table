Comprehensive Project Context

```markdown
# LiveTable Project - Current State & Next Steps

## Overview
LiveTable is a reusable Phoenix LiveView component for building data tables with sorting, pagination, filtering, and multiple view modes (table/card). It supports both auto-generated queries for simple cases and custom data providers for complex scenarios.

## Current Architecture

### Core Components
1. **LiveResource** - Main macro that provides table functionality
2. **TableComponent** - UI rendering (table and card modes)
3. **LiveViewHelpers** - Handles LiveView events and URL params
4. **TableConfig** - Configuration and defaults management

### Key Design Decisions Made

#### 1. Hybrid Data Approach ✅
- **Simple case**: Schema + basic fields → auto-generated queries
- **Complex case**: Custom data provider → full user control
- **Implementation**:
  ```elixir
  # Simple
  use LiveTable.LiveResource, schema: User

  # Complex
  use LiveTable.LiveResource  # No schema
  assign(socket, :dynamic_data_provider, {Context, :function, [args]})
  ```

#### 2. Field vs Filter Pattern ✅
- **Fields**: Either base schema fields OR custom query results (field keys must match query select keys)
- **Filters**: Always use `assoc: {:table_name, :field}` pattern for joins
- **Rationale**: Fields handle display, filters handle querying - different concerns

#### 3. Streams Only ✅
- **Decision**: Use Phoenix streams exclusively, no assigns fallback
- **Rationale**: Better performance, simpler codebase, no conditional complexity

#### 4. Multi-Mode Support ✅
- **Table mode**: Traditional rows/columns with sortable headers
- **Card mode**: Grid layout with custom user components
- **Sorting**: Table mode = column headers, Card mode = simple dropdown
- **Implementation**: Pattern matching in components, no if-else

### Current Implementation Status

#### ✅ Completed
1. **Basic LiveResource structure** - Macro with overridable functions
2. **Dynamic data providers** - `{module, function, args}` pattern
3. **Field configuration** - Labels, sorting, searching, rendering
4. **Filter system** - Boolean, Select, Range filters with auto-joins
5. **Table/Card mode switching** - Pattern-matched components
6. **Sorting for both modes** - Headers for table, dropdown for card
7. **Pagination** - With streams support
8. **Join logic** - Auto-joins for filters, user-controlled for display

#### 🚧 In Progress / Next Steps
1. **Custom header components** - Allow users to override header UI
2. **Filter join optimization** - Ensure no duplicate joins
3. **Documentation** - API docs and usage examples
4. **Error handling** - Better error messages for common mistakes

### Code Patterns & Conventions

#### ✅ Follow These Patterns
```elixir
# 1. Dynamic data provider
def mount(params, _session, socket) do
  socket = assign(socket, :dynamic_data_provider, {Context, :function, [id]})
  {:ok, socket}
end

# 2. Field keys match query select keys
def fields do
  %{
    program_name: %{label: "Program", sortable: true}  # Must match query
  }
end

# Query must return
select: %{program_name: p.name}  # Exact match

# 3. Pattern matching for modes
defp content_section(%{mode: :table} = assigns), do: # table view
defp content_section(%{mode: :card} = assigns), do: # card view

# 4. Filter associations
filters: %{
  supplier_name: Select.new({:suppliers, :name}, "supplier", %{
    condition: dynamic([r, suppliers: s], s.name == ^name)
  })
}
```

#### ❌ Avoid These Patterns
```elixir
# 1. Don't use assoc in field definitions anymore
fields: %{
  supplier_name: %{assoc: {:suppliers, :name}}  # ❌ Removed
}

# 2. Don't use conditional rendering in templates
<%= if @mode == :table do %>  # ❌ Use pattern matching instead

# 3. Don't mix simple and complex approaches
use LiveTable.LiveResource, schema: User, data_provider: {...}  # ❌ Pick one
```

### File Structure
```
live_table/
├── lib/live_table/
│   ├── live_resource.ex          # Main macro
│   ├── table_component.ex        # UI rendering
│   ├── live_view_helpers.ex      # Event handling
│   ├── table_config.ex           # Configuration
│   ├── sorting.ex                # Sort logic
│   ├── join.ex                   # Auto-join logic for filters
│   ├── filter.ex                 # Filter application
│   ├── paginate.ex               # Pagination logic
│   └── filters/
│       ├── boolean.ex            # Checkbox filters
│       ├── select.ex             # Dropdown filters
│       └── range.ex              # Range filters
```

### Current Challenges & Solutions

#### Challenge 1: Field-Filter Integration
**Problem**: Custom queries might not include all fields that filters reference
**Solution**: Auto-join logic in `join.ex` adds necessary joins for filters only

#### Challenge 2: Performance with Joins
**Problem**: Filters adding unnecessary joins
**Solution**: `Enum.uniq()` prevents duplicate joins, LEFT JOINs for optional filters

#### Challenge 3: User Learning Curve
**Problem**: Two different patterns (fields vs filters)
**Solution**: Clear documentation and examples showing when to use each

### Next Implementation Steps

#### 1. Custom Header Components (Priority 1)
```elixir
# Goal: Allow this
def table_options do
  %{
    custom_header: {MyAppWeb.JEEHeader, :render}
  }
end

# Implementation needed in TableComponent
defp header_section(assigns) do
  case get_in(assigns.table_options, [:custom_header]) do
    {module, function} -> apply(module, function, [prepare_header_assigns(assigns)])
    nil -> default_header_section(assigns)
  end
end
```

#### 2. Enhanced Documentation (Priority 2)
- Complete API documentation
- Migration guide from assoc-based fields
- Custom component examples
- Performance best practices

#### 3. Error Handling (Priority 3)
- Validate field keys match query select keys
- Better error messages for common mistakes
- Debugging helpers

#### 4. Testing Suite (Priority 4)
- Unit tests for each component
- Integration tests for full workflows
- Performance tests with large datasets

### Configuration Examples

#### Simple Table
```elixir
defmodule ProductsResource do
  use LiveTable.LiveResource, schema: Product

  def fields do
    %{
      name: %{label: "Name", sortable: true, searchable: true},
      price: %{label: "Price", sortable: true}
    }
  end
end
```

#### Complex Table with Custom Query
```elixir
defmodule CollegeProgramsResource do
  use LiveTable.LiveResource

  def mount(params, _session, socket) do
    college_id = extract_id(params)
    socket = assign(socket, :dynamic_data_provider, {Colleges, :list_programs, [college_id]})
    {:ok, socket}
  end

  def fields do
    %{
      program_name: %{label: "Program", sortable: true},
      opening_rank: %{label: "Opening Rank", sortable: true, assoc: {:rank_cutoff, :opening_rank}}
    }
  end

  def filters do
    %{
      category: Select.new({:rank_cutoff, :category}, "category", %{...})
    }
  end
end

# Context function
def list_programs(college_id) do
  from c in College,
    join: cp in CollegeProgram, on: cp.college_id == c.id,
    join: p in Program, on: p.id == cp.program_id,
    join: rc in RankCutoff, on: rc.college_program_id == cp.id, as: :rank_cutoff,
    where: c.id == ^college_id,
    select: %{
      program_name: p.name,      # Must match field key
      opening_rank: rc.opening_rank  # Must match field key
    }
end
```

#### Card Mode with Custom Component
```elixir
def table_options do
  %{
    mode: :card,
    card_component: &MyAppWeb.CollegeCard.card/1,
    card: %{grid_cols: 3, gap: 4}
  }
end

# Card component
defmodule MyAppWeb.CollegeCard do
  def card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow p-6">
      <h3>{@record.program_name}</h3>
      <p>Opening Rank: {@record.opening_rank}</p>
    </div>
    """
  end
end
```

### Performance Considerations
- Use streams for all data (implemented)
- Minimize joins in custom queries
- Index frequently sorted/filtered columns
- Use LIMIT/OFFSET for pagination (implemented)

### Breaking Changes Made
1. Removed `assoc:` from field definitions
2. Changed to dynamic data provider assignment
3. Simplified to streams-only approach

This context document should be used for future development and helps maintain consistency in the codebase.
```

This comprehensive context covers everything we've discussed and decided. Use this as reference for future
