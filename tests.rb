require "test/unit"

class TestJournal < Test::Unit::TestCase

  DB_FILE = "test.sqlite.db"

  def setup
    `./journal.rb log ralph 10 "asked me about test reports" #{DB_FILE}`
    `./journal.rb log sara 5 "needed help with a SQL query" #{DB_FILE}`
    `./journal.rb log ralph 17 "asked me again about test reports. aargh, why won't he shut up??" #{DB_FILE}`
    `./journal.rb log lynn 13 "reported a bug" #{DB_FILE}`
  end

  def teardown
    system "rm -f #{DB_FILE}"
  end

  def test_total
    assert_match(/45/, `./journal.rb total #{DB_FILE}`, "Journal must contains 45 minutes of duration")
  end

  def test_list
    assert_match(/ralph\s+10/, `./journal.rb list #{DB_FILE}`, "Journal must contain log entry ralph 10")
    assert_match(/sara\s+5/, `./journal.rb list #{DB_FILE}`, "Journal must contain log entry sara 5")
    assert_match(/ralph\s+17/, `./journal.rb list #{DB_FILE}`, "Journal must contain log entry ralph 17")
    assert_match(/lynn\s+13/, `./journal.rb list #{DB_FILE}`, "Journal must contain log entry lynn 13")
  end

  def test_hitlist
    assert_match(/ralph\s+27/, `./journal.rb hitlist #{DB_FILE}`, "Journal must contain hitlist entry ralph 27")
    assert_match(/sara\s+5/, `./journal.rb hitlist #{DB_FILE}`, "Journal must contain hitlist entry sara 5")
    assert_match(/lynn\s+13/, `./journal.rb hitlist #{DB_FILE}`, "Journal must contain hitlist entry lynn 13")
  end

end
