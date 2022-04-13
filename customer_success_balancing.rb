# frozen_string_literal: true

require 'minitest/autorun'
require 'timeout'

# Balance Customers in Customer Success Partitions and Selects The Best Option
class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  def execute
    grouped_customers = group_customers_in_customer_success_partitions
    select_the_best_customer_success(grouped_customers)
  end

  private

  def group_customers_in_customer_success_partitions
    customers_partitions = {}

    active_customer_success = exclude_away_customer_success

    active_customer_success.sort_by! { |customer_success| customer_success[:score] }
    active_customer_success.each { |customer_success| customers_partitions[customer_success] = [] }

    @customers.each do |customer|
      partition = customers_partitions[active_customer_success
                  .find { |customer_success| customer[:score] <= customer_success[:score] }]
      partition&.push(customer)
    end

    customers_partitions
  end

  def exclude_away_customer_success
    @customer_success.reject do |customer_success_item|
      @away_customer_success.include?(customer_success_item[:id])
    end
  end

  def select_the_best_customer_success(grouped_customers)
    customers_count_per_customer_success = grouped_customers_by_count(grouped_customers)

    best_customer_success = find_best_customer_success_value(
      customers_count_per_customer_success
    )

    return 0 if best_customer_success.nil? || (best_customer_success[:customer_quantity]).zero?
    return 0 if check_uniqueness_best_customer_success(customers_count_per_customer_success, best_customer_success)

    best_customer_success[:customer_success][:id]
  end

  def check_uniqueness_best_customer_success(customers_quantity, best_customer_success)
    (customers_quantity.find_all do |customers_count|
      customers_count[1] == best_customer_success[:customer_quantity]
    end).count > 1
  end

  def find_best_customer_success_value(customers_count_per_customer_success)
    selected_customer_success = { customer_success: {}, customer_quantity: 0 }

    customers_count_per_customer_success.each do |item|
      customer_success = item[0]
      customer_quantity = item[1]

      next unless customer_quantity > selected_customer_success[:customer_quantity]

      selected_customer_success = { customer_success:, customer_quantity: }
    end

    selected_customer_success
  end

  def grouped_customers_by_count(grouped_customers)
    grouped_customers_by_count = []

    grouped_customers.each do |grouped_customer|
      customer_success = grouped_customer[0]
      customer_quantity = grouped_customer[1].size

      grouped_customers_by_count << [customer_success, customer_quantity]
    end

    grouped_customers_by_count
  end

  def valid_unique_best_customer_success(groups, max_customer_success_size)
    count = 0

    groups.each do |group|
      count += 1 if group.values[0] == max_customer_success_size
    end

    count == 1
  end
end

# Customer Success Balacing Test Scenarios
class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10_000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  def test_scenario_eight
    balancer = CustomerSuccessBalancing.new(
      build_scores([10]),
      build_scores([20, 30, 40]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_nine
    balancer = CustomerSuccessBalancing.new(
      build_scores([]),
      build_scores([20, 30, 40]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_nine
    balancer = CustomerSuccessBalancing.new(
      build_scores([50]),
      build_scores([20, 30, 40]),
      [1]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_ten
    balancer = CustomerSuccessBalancing.new(
      build_scores([10, 20, 30, 40]),
      build_scores([]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_eleven
    balancer = CustomerSuccessBalancing.new(
      build_scores([10, 20, 30, 40]),
      build_scores([1]),
      [2, 3, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_twelve
    balancer = CustomerSuccessBalancing.new(
      build_scores([10, 20, 30, 40]),
      build_scores([1]),
      [1, 2, 3]
    )
    assert_equal 4, balancer.execute
  end

  def test_scenario_thirteen
    balancer = CustomerSuccessBalancing.new(
      build_scores([10, 20, 30, 40]),
      build_scores([]),
      [1, 2, 3, 4]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_fourteen
    balancer = CustomerSuccessBalancing.new(
      build_scores([50, 100]),
      build_scores([20, 30, 35, 40, 60, 80]),
      []
    )
    assert_equal 1, balancer.execute
    
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: }
    end
  end
end
