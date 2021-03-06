defmodule FdWeb.InstanceView do
  use FdWeb, :view

  alias Fd.Instances.Instance

  def version_build_label(string) do
    with \
      [_, builds] <- String.split(string, "+", parts: 2),
      build = String.slice(builds, 0..15)
    do
      content_tag(:div, content_tag(:small, build), [title: builds])
    else
      err ->
        ""
    end
  end

  def simplify_version(nil), do: nil
  def simplify_version(""), do: ""

  def simplify_version("v"<>string), do: simplify_version(string)

  def simplify_version(string) do
    full_string = string
    {string, build} = case String.split(string, "+", parts: 2) do
      [string, build] -> {string, build}
      [string] -> {string, nil}
    end

    {suffix, simple_version} = cond do
      String.match?(string, ~r/^[0-9a-z]+$/) and String.length(string) > 8 ->
        << string :: binary-size(8), _ :: binary >> = string
        {"*", string}
      String.match?(string, ~r/^[0-9a-z]+$/) ->
        {nil, string}
      true ->
        simplify_version_string(full_string)
    end

    suffix = if build, do: "+", else: suffix


    cond do
      suffix && simple_version -> content_tag(:span, [simple_version, content_tag(:sup, suffix)], [title: full_string])
      suffix -> content_tag(:span, content_tag(:sup, suffix), [title: full_string])
      true -> string
    end
  end

  def simplify_version_string(string) do
    case String.split(string, ~r/[^0-9.]/, parts: 2) do
      [simple, ext] -> {"*", simple}
      [version] ->
        if String.length(version) >= 8 do
          {"*", nil}
        else
          {nil, nil}
        end
    end
  end

  def simplify_version(value), do: value

  # TODO: Update when instances has a "protocols" field
  def supported_protocols(instance) do
    nodeinfo = get_in(instance.nodeinfo, ["protocols"]) || []
    if nodeinfo && !Enum.empty?(nodeinfo) do
      nodeinfo
    else
      server_data = Fd.ServerName.data(instance.server)||%{}
      Map.get(server_data, :protocols, [])
    end
  end

  def supported_protocols_list(instance) do
    protocols = supported_protocols(instance)
    unless Enum.empty?(protocols) do
      protos = Enum.map(protocols, fn(protocol) ->
        data = Fd.ServerName.get_protocol_data(protocol)
        if data do
          img = img_tag(data.logo, alt: data.name, class: "icon")
          link([img, raw("&nbsp;"), data.name], title: data.name, to: "/protocols/#{protocol}", class: "protocol-link")
        end
      end)
      |> Enum.filter(fn(p) -> p end)
      content_tag(:span, protos, class: "protocols-list")
    end
  end

  def statistic_column(label, value), do: statistic_column(label, value, [])
  def statistic_column(label, nil, options), do: nil
  def statistic_column(label, value, options) do
    value = content_tag(:div, value, class: "value")
    label = content_tag(:div, label, class: "label")
    statistic = content_tag(:div, [label, value], class: "statistic")
    col_class = Keyword.get(options, :class, "col-sm")
    content_tag(:div, statistic, class: col_class)
  end

  def chart_tag_lazy(conn, idx, instance, names, params) do
    chart_tag_lazy(conn, idx, instance, names, params, [])
  end

  def chart_tag_lazy(conn, idx, instance, names, params, img_params) when idx < 25 do
    chart_tag(conn, instance, names, params, img_params)
  end
  def chart_tag_lazy(conn, idx, instance, names, params, img_params) do
    path = instance_chart_path(conn, :show, instance, names, params)
    opts = img_params
    |> Keyword.put(:"data-src", path)
    |> Keyword.put(:class, "lazy chartd")
    tag(:img, opts)
  end

  def chart_tag(conn, instance, names, params, img_params \\ []) do
    path = instance_chart_path(conn, :show, instance, names, params)
    img_tag(path, Keyword.put(img_params, :class,  "chartd"))
  end

  def active_section_class(%{assigns: %{section: active_section}}, section) when active_section == section do
    "active"
  end
  def active_section_class(_, _), do: ""

  def display_stat(stats, format, keys) do
    value = get_in(stats, keys)
    if value do
      format_stat(format, keys, value)
    end
  end
  def display_stats(stats, format, key, keys) do
    value = get_in(stats, key)
    if value do
      stats = keys
              |> Enum.map(fn(sub_key) -> {[key, sub_key], Map.get(value, sub_key)} end)
              |> Enum.filter(fn({_, value}) -> value end)
              |> Enum.uniq_by(fn({_, value}) -> value end)
              |> Enum.map(fn({keys, value}) -> format_stat(:inline, keys, value) end)
              |> Enum.intersperse("/")
      if format == :mini do
        ["(", stats, ")"]
      else
        stats
      end
    end
  end


  def format_stat(:mini, keys, value) do
    content_tag(:span, ["(", to_string(value), ")"], title: join(keys, " "), class: "stat-"<>join(keys, "-"))
  end
  def format_stat(:inline, keys, value) do
    content_tag(:span, to_string(value), title: join(keys, " "), class: "stat-"<>join(keys, "-"))
  end

  def name(instance), do: name(instance, [])
  def name(instance = %Instance{name: name}, options) when is_binary(name) do
    name = clean_name(String.downcase(instance.name), String.downcase(instance.domain))
    if name do
      if Keyword.get(options, :domain, true) do
        domain = content_tag(:span, ["(", idna(instance.domain), ")"], class: "instance-domain")
        [instance.name, " ", domain]
      else
        instance.name
      end
    else
      idna(instance.domain)
    end
  end
  def name(instance, options), do: idna(instance.domain)

  def li_item(_, nil), do: nil

  def li_item(title, var) do
    title = content_tag(:strong, title)
    content_tag(:li, [title, ": ", to_string(var)])
  end

  def up_bootstrap_table_class(%Instance{up: true}), do: "success"
  def up_bootstrap_table_class(%Instance{up: false}), do: "danger"
  def up_bootstrap_table_class(_), do: "warning"

  def active_class_bool(true), do: "active"
  def active_class_bool(_), do: ""

  def clean_name("mastodon", _), do: nil
  def clean_name("pleroma", _), do: nil
  def clean_name(name, domain) when name == domain, do: nil
  def clean_name(nil, _), do: nil
  def clean_name(name, _), do: name

  def server_info("known"), do: nil
  def server_info(name) when is_binary(name) do
    server_info(Fd.ServerName.to_int(name))
  end
  def server_info(id) when is_integer(id) do
    case Fd.ServerName.data(id) do
      data when is_map(data) ->
        render("_server_info.html", data: data)
      _ -> nil
    end
  end
  def server_info(_), do: nil

  def uptime_percentage(%Instance{id: id}) do
    if uptime = Fd.Instances.get_uptime_percentage(id) do
      Float.floor(uptime)
    else
      nil
    end
  end

  defp join(keys, joiner) do
    keys
    |> Enum.map(fn
      ["per_server", id, key] -> [Fd.ServerName.from_int(id), key]
      val -> val
    end)
    |> List.flatten()
    |> Enum.join(joiner)
  end

end
