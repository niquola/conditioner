require File.dirname(File.expand_path(__FILE__)) + '/test_helper.rb'

Conditioner.configure do |cfg|
  #Must be activated by default
  #cfg.activate_default_rules!
  #You can clear default rules with
  #cfg.clear_rules!

  cfg.add_rule do |key, value, cnd|
    if /(.\w*)_gt/ =~ key.to_s && cnd.is_field?($1)
      cnd.and(["#{key.gsub(/_gt$/,'')} > ? ", value])
    end
  end
end

# FIXME: we are depending on Time.zone now...
# This is required for Time.zone to work correctly
Time.zone ||= ENV['TZ'] || 'UTC'

class TestConditioner < Test::Unit::TestCase

  def test_conditioner_creation
    cnd = User.conditioner
    assert_not_nil(cnd)
    params={:name=>'nicola',:email=>'nicola@mail.com'}
    cnd = User.conditioner(params)
    assert_not_nil(cnd)
  end

  def test_extraction
    cnd=User.conditioner(:updated_at=>'2009-01-01', :email=>'nicola@mail.com',:unexisting=>'value')
    assert_match(/"users"."email"\s*=\s*'nicola@mail.com'/, cnd)
    assert_match(/users.updated_at BETWEEN '2009-01-01 00:00:00/,cnd)
    assert_match(/AND '2009-01-01 23:59:59/, cnd)
    assert_no_match(/unexisting/, cnd)
    User.all(:conditions=>cnd)
  end

  def test_extract_from_and_to_prefixed_date_fields
    cnd = User.conditioner :to_updated_at =>'2010-02-02', 
      :from_updated_at=>'2009-01-01'
    assert_match(/updated_at <= '2010-02-02 23:59:59/, cnd)
    assert_match(/updated_at >= '2009-01-01 00:00:00/, cnd)
    User.all(:conditions=>cnd)
  end

  def test_extract_lt_and_gt_postfixed_fields
    cnd = User.conditioner :id_lt => '5', :id_gt => 2
    assert_match(/id < '5'/, cnd)
    assert_match(/id > 2/, cnd)
  end

  def test_extract_ltoe_and_gtoe_postfixed_fields
    cnd = User.conditioner :id_ltoe => '5', :id_gtoe => 2
    assert_match(/id <= '5'/, cnd)
    assert_match(/id >= 2/, cnd)
  end

  def test_begins_ends_contains_rules
    cnd = User.conditioner :email_begins_with => "a", :email_ends_with => "b", :email_contains => "c"
    assert_match(/email ILIKE 'a%'/, cnd)
    assert_match(/email ILIKE '%b'/, cnd)
    assert_match(/email ILIKE '%c%'/, cnd)
    cnd = User.conditioner :email_begins_with => ""
    assert_no_match(/email ILIKE/, cnd,'must not empty values')
  end

  def test_in_postfixed_field
    cnd = User.conditioner :email_in => ['a', 'b', 'c']
    assert_match(/email IN \('a','b','c'\)/, cnd)
  end

  def test_ilike
    cnd = User.conditioner :name=> '*nicola*'
    assert_match(/name ILIKE '%nicola%'/, cnd)
    assert_no_match(/\*nicola\*/, cnd, 'Rule must work only once!')
  end

  def test_configurator
    cnd = User.conditioner :created_at_gt => '2010-01-01'
    assert_match(/created_at > '2010-01-01'/, cnd)
  end

  def test_dates_from_to
    cnd = User.conditioner :from_created_at => '2010-01-01', :to_created_at => '2010-01-01'
    assert_match(/created_at >= '2010-01-01 00:00:00/, cnd)
    assert_match(/created_at <= '2010-01-01 23:59:59/, cnd)
  end

  def test_conditioner_without_model
    cnd = Conditioner.create('users', :columns => ['id', 'email']).extract(:email => "nicola", :foo => "bar")
    assert_equal(%Q["users"."email" = 'nicola'], cnd)
  end

  def test_conditioner_without_model_with_advanced_rules
    cnd = Conditioner.create('users', :columns => ['id', 'email']).extract(:email => "*nicola*")
    assert_match(/email ILIKE '%nicola%'/, cnd)
  end

  def test_conditioner_without_model_and_without_hardcoded_columns
    cnd = Conditioner.create('users').extract(:email => "nicola", :foo => "bar")
    assert_equal(%Q["users"."email" = 'nicola'], cnd)
  end

end
