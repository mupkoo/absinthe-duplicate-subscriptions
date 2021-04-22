defmodule ShowcaseWeb.Schema do
  use Absinthe.Schema

  object :item do
    field :title, :string
  end

  query do
  end

  subscription do
    field :change, :item do
      arg :id, non_null(:id)
      config fn %{id: id}, _ -> {:ok, topic: id, context_id: "global"} end
    end

    field :change_private, :item do
      arg :id, non_null(:id)
      config fn %{id: id}, _ -> {:ok, topic: id} end
    end

    field :change_no_args, :item do
      config fn _, _ -> {:ok, topic: "*", context_id: "global"} end
    end
  end
end
