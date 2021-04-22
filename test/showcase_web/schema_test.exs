defmodule ShowcaseWeb.SchemaTest do
  use ShowcaseWeb.ChannelCase
  use Absinthe.Phoenix.SubscriptionTest, schema: ShowcaseWeb.Schema

  @subscription """
    subscription change($id: ID!) {
      change(id: $id) { title }
    }
  """
  test "it pushes multiple times per subscription when there is fixed context_id" do
    subscriptions =
      for _i <- 1..5 do
        connect()
        |> push_doc(@subscription, variables: %{id: "2"})
        |> assert_reply(:ok, %{subscriptionId: subscription_id}, 250)

        subscription_id
      end

    assert [subscription_id] = Enum.uniq(subscriptions)

    Absinthe.Subscription.publish(
      ShowcaseWeb.Endpoint,
      %{title: "Let's go!"},
      change: "2"
    )

    # Since we have 5 connections opened and 5 subscriptions
    # we get 25 pushes (5 each)
    for _i <- 1..25 do
      assert_push "subscription:data", %{
        result: %{data: %{"change" => %{"title" => "Let's go!"}}},
        subscriptionId: ^subscription_id
      }
    end

    refute_push "subscription:data", %{}
  end

  @subscription """
    subscription changePrivate($id: ID!) {
      changePrivate(id: $id) { title }
    }
  """
  test "it pushes just once per subscription when there is no context_id set" do
    subscriptions =
      for _i <- 1..5 do
        connect()
        |> push_doc(@subscription, variables: %{id: "2"})
        |> assert_reply(:ok, %{subscriptionId: subscription_id}, 250)

        subscription_id
      end

    assert subscriptions |> Enum.uniq() |> Enum.count() == 5

    Absinthe.Subscription.publish(
      ShowcaseWeb.Endpoint,
      %{title: "Let's go!"},
      change_private: "2"
    )

    for subscription_id <- subscriptions do
      assert_push "subscription:data", %{
        result: %{data: %{"changePrivate" => %{"title" => "Let's go!"}}},
        subscriptionId: ^subscription_id
      }

      # It is pushed just once per subscription
      refute_push "subscription:data", %{
        result: %{data: %{"changePrivate" => %{"title" => "Let's go!"}}},
        subscriptionId: ^subscription_id
      }
    end
  end

  @subscription """
    subscription changeNoArgs {
      changeNoArgs { title }
    }
  """
  test "it pushes multiple times per subscription, even if there are not args" do
    subscriptions =
      for _i <- 1..5 do
        connect()
        |> push_doc(@subscription)
        |> assert_reply(:ok, %{subscriptionId: subscription_id}, 250)

        subscription_id
      end

    assert [subscription_id] = Enum.uniq(subscriptions)

    Absinthe.Subscription.publish(
      ShowcaseWeb.Endpoint,
      %{title: "Let's go!"},
      change_no_args: "*"
    )

    # Since we have 5 connections opened and 5 subscriptions
    # we get 25 pushes (5 each)
    for _i <- 1..25 do
      assert_push "subscription:data", %{
        result: %{data: %{"changeNoArgs" => %{"title" => "Let's go!"}}},
        subscriptionId: ^subscription_id
      }
    end

    refute_push "subscription:data", %{}
  end

  def connect() do
    {:ok, socket} = Phoenix.ChannelTest.connect(ShowcaseWeb.UserSocket, %{})
    {:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)
    socket
  end
end
