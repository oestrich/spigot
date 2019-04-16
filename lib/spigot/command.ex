defmodule Spigot.Command do
  @moduledoc """
  Functions for a command

  Push and render output
  """

  def forward(conn, process, message) do
    Map.put(conn, :messages, conn.messages ++ [{process, message}])
  end

  def event(conn, process, module, action, params \\ %{}) do
    forward(conn, process, struct(module, %{action: action, params: params}))
  end

  def push(conn, lines) do
    Map.put(conn, :lines, conn.lines ++ List.wrap(lines))
  end

  def render(conn, template) do
    render(conn, conn.private.view, template, %{})
  end

  def render(conn, template, assigns) when is_binary(template) and is_map(assigns) do
    render(conn, conn.private.view, template, assigns)
  end

  def render(conn, view, template) when is_atom(view) and is_binary(template) do
    render(conn, view, template, %{})
  end

  def render(conn, view, template, assigns) do
    push(conn, view.render(template, Map.merge(conn.assigns, assigns)))
  end
end
