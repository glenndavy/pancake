require File.dirname(__FILE__) + '/../../spec_helper'

describe "Pancake::Controller publish declaration" do
  before(:each) do
    class ::PancakeTest
      extend Pancake::Mixins::Publish
      
      provides :html
      
      publish
      def simple_publish; end
      
      publish :id => as(:integer)
      def integer_test; end
      
      publish :start => as(:date)
      def date_test; end
      
      publish :page => as(:integer, 12)
      def default_test; end
      
      publish :provides => [:xml, :json]
      def provides_test; end
      
      publish :only_provides => :xml
      def only_provides_test; end
      
      publish :name => as(:string, :opt)
      def optional_test; end
      
      publish :provides => [:json, :txt],
              :id       => as(:integer, :req), 
              :name     => as(:string, "Campion"), 
              :melon    => as(:integer, 50),
              :jam      => as(:string, :opt),
              :squeeze  => as(:string, :req)
      def complex_test; end
    end
  end
  
  after do 
    clear_constants "PancakeTest"
  end
  
  it "should publish an action" do
    PancakeTest.actions['simple_publish'].is_a?(Pancake::Mixins::Publish::ActionOptions).should == true
  end
  
  it "should coerce a parameter into an integer" do
    params, missing = PancakeTest.__send__(:validate_and_coerce_params, 'integer_test', 'id' => "30")
    params['id'].should == 30
  end
  
  it "should coerce a parameter into a date" do
    date = Date.parse("2009/07/05")
    params, missing = PancakeTest.__send__(:validate_and_coerce_params, 'date_test', 'start' => "2009/07/05")
    params['start'].should == date
  end
  
  it "should flag required params that are missing" do
    params, missing = PancakeTest.__send__(:validate_and_coerce_params, 'integer_test', {})
    missing.include?(['id', :integer]).should == true
  end
  
  it "should allow parameters to be optional" do
    params, missing = PancakeTest.__send__(:validate_and_coerce_params, 'optional_test', {})
    missing.empty?.should == true
  end
  
  it "should return a default value for a parameter" do
    params, missing = PancakeTest.__send__(:validate_and_coerce_params, 'default_test', {})
    params['page'].should == 12
  end
  
  it "should append formats to the list allowed for an action" do
    PancakeTest.actions['provides_test'].formats.should == [:html, :xml, :json]
  end
  
  it "should replace the list of formats allowed for an action" do
    PancakeTest.actions['only_provides_test'].formats.should == [:xml]
  end
  
  it "should allow complex declarations" do
    input = {'id' => "30", 'name' => "Purslane"}
    params, missing = PancakeTest.__send__(:validate_and_coerce_params, 'complex_test', input)
    params['id'].should == 30
    params['name'].should == "Purslane"
    params['melon'].should == 50
    params['jame'].should be_nil
    missing.include?(['squeeze', :string]).should == true
    
    PancakeTest.actions['complex_test'].formats.should == [:html, :json, :txt]
  end
end
