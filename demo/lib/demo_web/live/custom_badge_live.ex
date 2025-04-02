defmodule DemoWeb.CustomBadgeLive do
  use DemoWeb, :live_view

  use LiveTable.LiveResource, schema: Demo.HR.Employee

  def mount(_params, _session, socket) do
    socket = socket |> assign(:page_title, "Custom Badge Demo")
    {:ok, socket}
  end

  def fields do
    [
      id: %{
        label: "ID",
        sortable: true
      },
      name: %{
        label: "Name",
        sortable: true
      },
      email: %{
        label: "Email",
        sortable: true
      },
      department: %{
        label: "Department",
        sortable: true,
        renderer: &department_badge/1
      },
      level: %{
        label: "Level",
        sortable: true,
        renderer: &level_badge/1
      },
      active: %{
        label: "Active",
        sortable: false,
        renderer: &active_badge/1
      }
    ]
  end

  def filters do
    [
      active: Boolean.new(:level, "true", %{label: "Active", condition: dynamic([p], p.active == true)}),
      level_filter: Boolean.new(:level, "senior", %{label: "Senior", condition: dynamic([p], p.level == "senior")})
      # select filter here
    ]
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="py-1">
        <h1 class="text-2xl font-semibold mb-4 dark:text-white">Basic Table Demo</h1>
        <p class="text-gray-600 mb-6 dark:text-gray-300">
          Demonstrates basic LiveTable features: sorting and pagination.
          Click on column headers to sort, use shift+click for multi-column sort.
        </p>

        <.live_table
          fields={fields()}
          filters={filters()}
          options={@options}
          streams={@streams}
        />
      </div>
    </div>
    """
  end

  def active_badge(true = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded-full dark:bg-green-900/30 dark:text-green-400">
      {assigns}
    </span>
    """
  end


  def active_badge(false = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-red-700 bg-red-100 rounded-full dark:bg-red-900/30 dark:text-red-400">
      {assigns}
    </span>
    """
  end

  def department_badge("Finance" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-blue-700 bg-blue-100 rounded-full dark:bg-blue-900/30 dark:text-blue-400">
      {assigns}
    </span>
    """
  end

  def department_badge("HR" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-purple-700 bg-purple-100 rounded-full dark:bg-purple-900/30 dark:text-purple-400">
      {assigns}
    </span>
    """
  end

  def department_badge("Marketing" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-orange-700 bg-orange-100 rounded-full dark:bg-orange-900/30 dark:text-orange-400">
      {assigns}
    </span>
    """
  end

  def department_badge("Sales" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded-full dark:bg-green-900/30 dark:text-green-400">
      {assigns}
    </span>
    """
  end

  def department_badge("Engineering" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-red-700 bg-red-100 rounded-full dark:bg-red-900/30 dark:text-red-400">
      {assigns}
    </span>
    """
  end

  def level_badge("senior" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-teal-700 bg-teal-100 rounded-full dark:bg-teal-900/30 dark:text-teal-400">
      {assigns}
    </span>
    """
  end

  def level_badge("lead" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded-full dark:bg-green-900/30 dark:text-green-400">
      {assigns}
    </span>
    """
  end

  def level_badge("mid" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-blue-700 bg-blue-100 rounded-full dark:bg-blue-900/30 dark:text-blue-400">
      {assigns}
    </span>
    """
  end

  def level_badge("junior" = assigns) do
    ~H"""
    <span class="px-2 py-1 text-xs font-medium text-yellow-700 bg-yellow-100 rounded-full dark:bg-yellow-900/30 dark:text-yellow-400">
      {assigns}
    </span>
    """
  end
end
