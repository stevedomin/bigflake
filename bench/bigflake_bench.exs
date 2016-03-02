defmodule  BigflakeBench do
  use Benchfella

  setup_all do
    Bigflake.start_link(0)
  end

  teardown_all _context do
    Bigflake.stop()
  end

  bench "mint ids" do
    Bigflake.mint()
    :ok
  end
end
