# ExDoubles

ExDoubles is an opinionated test doubles library for Elixir. It takes the stance that the easiest way to create loose coupling in your codebase is to follow the Dependency Inversion Principle (DIP) described below. 

Once your code follows DIP, **it is easy to construct adhoc mocks for any function.**

## Why another mock framework?

There are already a few other mock libraries for Elixir. However they either lack the ability to have ad-hoc mocking, or provide Erlang like syntax. 

ExDoubles wants you to wrap the code you don't own in a simple well defined interface, a function. Then you can mock that function and be on your way.

We also want Elixir to be popular. In order for that to happen, there needs to be a cohesive ecosystem. Tools should feel consistent and easy to learn. No Erlang knowledge should be required!

## Mocks
In order to start using ExDoubles in your test you have to start by adding `import ExDoubles` to your test module.

Now that you are importing the framework, you can construct a mock for the signature of any function, using the `mock` function. It takes a `label` for your function, and the `arity`. The arity argument makes sure your mock has the same number of arguments. Whereas the label is used by `verify` to check that your function was invoked in the correct way.

Let's build an example. First, we create a mock of the `save_fn` function. We specify a label and the arity we want it to have.

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

The complete test looks like this: 

```elixir
test "employee with no hours receives zero pay" do
  {:ok, mock_save_fn} = mock(:save_fn_label, 2)

  calculate_employee_pay([], "some_employee_id", mock_save_fn)

  assert verify(:save_fn_label, called_with(["some_employee_id", 0]))
end
```

## Stubs

ExDoubles allows the definition of stubbed values for a mocked function. By invoking the `when_called` function with a `label` and a value you wish to return, a stubbed value will be returned the next time the `mock` is called.

```elixir
test "returns stubbed value from a mock" do
  {:ok, mock_fn} = mock(:mock_label, 0)

  when_called(:mock_label, :stub_value)

  assert :stub_value == mock_fn.()
end
```

It is possible to defined multiple stub values. These are values are returned by the function in the order defined in the test.

```elixir
test "returns stubbed values in the order they were passed to `when_called`" do
  {:ok, mock_fn} = mock(:mock_label, 0)

  when_called(:mock_label, :stub_value_1)
  when_called(:mock_label, :stub_value_2)
  when_called(:mock_label, :stub_value_3)

  assert :stub_value_1 == mock_fn.()
  assert :stub_value_2 == mock_fn.()
  assert :stub_value_3 == mock_fn.()
end
```

## Matchers

Currently ExDoubles has two types of matchers *Call Count* and *Argument*. 

### Call Count matchers

Call Count matchers do pretty much what you would expect, they verify a function has been called some number of times. They are:

```elixir
assert verify(:mock_fn, once())
assert verify(:mock_fn, twice())
assert verify(:mock_fn, thrice())
assert verify(:mock_fn, times(10))
```

### Argument matcher

The only argument matcher at this time is `called_with`. This matcher takes a list of arguments that you expect a function to be invoked with. **It returns `truthy` or `falsey` which should be used with the ExUnit.Case `assert` function.**

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

With this principle applied to the code, we are ready to start using ExDoubles to create mocks.

## Installation

```elixir
def deps do
  [
    {:exdoubles, "~> 0.2", only: [:test]}
  ]
end
```
