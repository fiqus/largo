defmodule Largo.Responders.DemoResponder do
  @behaviour Largo.Responders.Responder

  @matchers [
    ~r/demo/iu,
  ]

  def respond(message) do
    if should_respond?(message) do
      {:ok, [
          "demo!",
          "demo 2",
          {"empty params", %{}},
          {"attachment_colors", %{attachments: Poison.encode!([
                                    %{fallback: "test color good", color: "good", text: "something good"},
                                    %{fallback: "test color warning", color: "warning", text: "something warningful"},
                                    %{fallback: "test color danger", color: "danger", text: "something dangerous"},
                                    %{fallback: "test color #AA0022", color: "#AA0022", text: "something #AA0022"}
                                  ])}}, 

          {"", %{attachments: Poison.encode!([%{fallback: "test short fields", 
                                                text: "test short fields", 
                                                fields: [%{
                                                           title: "Clave", 
                                                           value: "Valor",
                                                           short: true
                                                }]},
                                              %{fallback: "test long filds", 
                                                text: "etst long fields", 
                                                fields: [%{
                                                           title: "Clave", 
                                                           value: "Valor",
                                                           short: false
                                                }]}])}}]}
    else
      :noresponse
    end
  end

  defp should_respond?(message) do
    Enum.reduce_while(@matchers, false, fn re, _acc ->
      case Regex.run(re, message) do
        nil -> {:cont, false}
        _ -> {:halt, true}
      end
    end)
  end
end
