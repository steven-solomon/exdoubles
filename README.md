# Elephant

Elephant is an opinionated mocking library for Elixir. It takes the stance that the easiest way to create loose coupling in your codebase is to follow the Dependency Inversion Principle (DIP) described below. 

## Why another mock framework?

There are already a few other mock libraries for Elixir. However they either allow you to mock code you don't own, or provide Erlang like syntax. 

Mocking and testing in general are activities that give you feedback on the design of your code. If you mock functions that you don't own, you are learning about how difficult they are to test, but you can't respond to the pain. You are stuck with the design decisions of the framework authors.

Elephant wants you to wrap the code you don't own in a simple well defined interface, a function. Then you can then mock that function and be on your way.

We also want Elixir to be popular. In order for that to happen, there needs to be a cohesive ecosystem. Tools should feel consistent and easy to learn. No Erlang knowledge should be required!

## How does it work?
As consequence of applying the DIP, we can unit test a function by injecting in a mock functions as arguments. This is where Elephant shines!

You can construct a mock for the signature of any function, using the mock macro. It takes a `label` for your function, and the `arity`. The arity argument makes sure your mock has the same number of arguments. Whereas the label is used by the verify macro to check that your function was invoked in the correct way.

Let's build an example. First, we create a mock for the `save_fn` argument of a function we ware testing. We specify a label and the arity we want it to have.

```elixir
{:ok, mock_save_fn} = mock(:save_fn_label, 2)
```

Next we can pass the mock_save_fn into our function under test, `calculate_employee_pay`. 

```elixir
calculate_employee_pay([], "some_employee_id", mock_save_fn)
```

Lastly we verify that our function was invoked with the correct data. 

```elixir
assert verify(:save_fn_label, called_with(["some_employee_id", 0]))
```

A complete example test is:

```elixir
test "employee with no hours receives zero pay" do
  {:ok, mock_save_fn} = mock(:save_fn_label, 2)

  calculate_employee_pay([], "some_employee_id", mock_save_fn)

  assert verify(:save_fn_label, called_with(["some_employee_id", 0]))
end
```

## Stubbing 

Elephant can also allow you to return values from your mocks, this is called stubbing. 

```
test "returns stubbed value" do
  {:ok, no_arg_moc} = mock(:no_arg_label, 0, "stubbed_value")

  assert "stubbed_value" == no_arg_moc()
end
```

## Matchers

Currently Elephant has a few *Call Count* matchers and one *Argument* matcher.

### Call Count matchers

Call Count matchers do pretty much what you would expect. They are:

```elixir
assert verify(:mock_fn, once())
assert verify(:mock_fn, twice())
assert verify(:mock_fn, thrice())
assert verify(:mock_fn, times(10))
```

### Argument matcher

The only argument matcher at this time is `called_with` this function takes a `label` for a mock and the arguments it is expected to have received. It returns *truthy* or *falsey* which should be used with the ExUnit.Case `assert` function.

```elixir
assert verify(:mock_label, called_with([[], "some_user_id"]))
```

## Dependency Inversion Principle 
The Dependency Inversion Principle tells us that high level functions should not depend on low level ones, and both should depend on abstractions. An example is an application that calculates payroll.

In this example there is code that takes a list of hours for an employee id, and then saves that pay cycle value to the database.

```elixir
defmodule PayCycle do
  def calculate_employee_pay(hours, employee_id) do
    # ... complex calculation logic omitted 

    Db.PayRoll.save_payroll_to_database(employee_id, pay)
  end
end

defmodule Db.PayRoll do
  def save_payroll_to_database(employee_id, pay) do
   %PayRoll{
      employee_id: employee_id, 
      pay: calculated_value
    }
    |> PayRoll.changeset()
    |> Db.Repo
  end
end
```

In this example you will notice that the `Db.PayRoll.save_payroll_to_database` function is directly invoked by the high level module of calculating the pay for an employee. The Dependency Inversion Principle (DIP) recommends that the PayCycle module not depend directly on the Db.PayRoll module. So let's invert the dependency and have each depend on the function signature. The signature of the function can act as a sort of "contract" between the two modules.

Let's instead inject the save function when we want to run the PayCycle logic. This allows us to compose functions in new and interesting ways. 

```elixir
defmodule PayCycle do
  def calculate_employee_pay(hours, employee_id, save_payroll_fn) do
    # ... complex calculation logic omitted 

    save_payroll_fn.(employee_id, pay)
  end
end

defmodule Db.PayRoll do
  def save_payroll_to_database(employee_id, pay) do
   %PayRoll{
      employee_id: employee_id, 
      pay: calculated_value
    }
    |> PayRoll.changeset()
    |> Db.Repo
  end
end
```

With this principle applied to the code, we are ready to start using Elephant to create mocks.

## Installation

This project is currently in it's prototype stage, but is available to test out. Once we feel confident in it's stability, we will do a proper Hex release. Until then, **use at your own risk**!

```elixir
def deps do
  [
    {:elephant, git: "https://github.com/steven-solomon/elephant", only: [:test]}
  ]
end
```
