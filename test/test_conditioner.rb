require File.dirname(__FILE__) + '/test_helper.rb'


class TestConditioner < Test::Unit::TestCase

  def test_conditioner_creation
    cnd = User.conditioner
    assert_not_nil(cnd)
    params={:name=>'nicola',:email=>'nicola@mail.com'}
    cnd = User.conditioner(params)
    assert_not_nil(cnd)
  end

  def test_without_model_conditioner
    #table_name = 'roles'
    #fields = %w{name created_at}
    #Conditioner.condition(table_name,fields)
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
  end
end
