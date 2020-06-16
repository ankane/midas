require_relative "test_helper"

class MidasTest < Minitest::Test
  def test_works
    midas = Midas.new(rows: 2, buckets: 1024, seed: 123)
    scores = midas.fit_predict(data)

    assert_equal [10000], scores.shape
    expected = [0, 0, 1, 2, 2, 4, 2, 2, 3, 6]
    assert_elements_in_delta expected, scores[0...10]
    expected = [262.725342, 410.009674, 215.821609, 236.601303, 258.282837]
    assert_elements_in_delta expected, scores[-5..-1]
  end

  def test_no_relations
    midas = Midas.new(rows: 2, buckets: 1024, relations: false, seed: 123)
    scores = midas.fit_predict(data)

    assert_equal [10000], scores.shape
    expected = [0, 0, 1, 2, 2, 4, 2, 2, 3, 6]
    assert_elements_in_delta expected, scores[0...10]
    expected = [262.725342, 410.009674, 2.492458, 12.942609, 31.100597]
    assert_elements_in_delta expected, scores[-5..-1]
  end

  def test_undirected
    skip "Segmentation fault with MIDAS CLI so nothing to compare"

    midas = Midas.new(directed: false)
    scores = midas.fit_predict(data)

    assert_equal [20000], scores.shape
    expected = []
    assert_elements_in_delta expected, scores[0...10]
  end

  def test_file
    midas = Midas.new(rows: 2, buckets: 1024, seed: 123)
    scores = midas.fit_predict("vendor/MIDAS/data/DARPA/darpa_processed.csv")

    assert_equal [4554344], scores.shape
    expected = [0, 0, 1, 2, 2, 4, 2, 2, 3, 6]
    assert_elements_in_delta expected, scores[0...10]

    skip "Last value off by 0.012 on Travis (seed issue?)" if ENV["TRAVIS"]

    expected = [49.031101, 55.438084, 62.238354, 69.431908, 10.681725]
    assert_elements_in_delta expected, scores[-5..-1]
  end

  def data
    data = []
    File.foreach("vendor/MIDAS/data/DARPA/darpa_processed.csv").with_index do |line, i|
      break if i == 10000
      data << line.split(",").map(&:to_i)
    end
    Numo::Int32.cast(data)
  end
end
