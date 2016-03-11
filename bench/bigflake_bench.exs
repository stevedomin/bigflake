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

  bench "mint base62 ids" do
    Bigflake.mint(:base62)
    :ok
  end
end
