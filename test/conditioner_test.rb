require File.dirname(__FILE__) + '/test_helper.rb'

Conditioner.configure do |cfg|
  #Must be activated by default
  #cfg.activate_default_rules!
  #You can clear default rules with
  #cfg.clear_rules!

  cfg.add_rule do |key, value, cnd|
    if /(.\w*)_gt/ =~ key.to_s && cnd.is_field?($1) 
      cnd.and(["#{key.gsub(/_gt$/,'')} > ?",value])
    end
  end
end

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
    assert_match(/"users"."email"\s*=\s*E'nicola@mail.com'/, cnd)
    assert_match(/users.updated_at BETWEEN E'2009-01-01 00:00' AND E'2009-01-01 23:59:59.999'/, cnd)
    assert_no_match(/unexisting/, cnd)
  end

  def test_extract_from_and_to_prefixed_date_fields
    cnd = User.conditioner :to_updated_at =>'2010-02-02', :from_updated_at=>'2009-01-01'
    assert_match(/updated_at <= E'2010-02-02 23:59:59.999'/, cnd)
    assert_match(/updated_at >= E'2009-01-01 00:00:00.000'/, cnd)
  end

  def test_ilike
    cnd = User.conditioner :name=>'*nicola*'
    assert_match(/name ILIKE E'%nicola%'/, cnd)
    assert_no_match(/\*nicola\*/, cnd,'Rule must work only once!')
  end

  def test_configurator
    cnd = User.conditioner :created_at_gt => '2010-01-01'
    assert_match(/created_at > E'2010-01-01'/, cnd)
  end
end
