require File.dirname(__FILE__) + '/spec_helper.rb'

include RR

describe DirectTableScan do
  before(:each) do
    Initializer.configuration = standard_config
  end

  it "run should compare all the records in the table" do
    session = Session.new
    scan = DirectTableScan.new session, 'scanner_records'
    diff = []
    scan.run do |type, row|
      diff.push [type, row]
    end
    # in this scenario the right table has the 'highest' data, 
    # so 'right-sided' data are already implicitely tested here
    diff.should == [
      [:conflict, [
          {'id' => 2, 'name' => 'Bob - left database version'},
          {'id' => 2, 'name' => 'Bob - right database version'}]],
      [:left, {'id' => 3, 'name' => 'Charlie - exists in left database only'}],
      [:right, {'id' => 4, 'name' => 'Dave - exists in right database only'}],
      [:left, {'id' => 5, 'name' => 'Eve - exists in left database only'}],
      [:right, {'id' => 6, 'name' => 'Fred - exists in right database only'}]
    ]
  end

  it "run should handle one-sided data" do
    # separate test case for left-sided data; right-sided data are already covered in the general test
    session = Session.new
    scan = DirectTableScan.new session, 'scanner_left_records_only'
    diff = []
    scan.run do |type, row|
      diff.push [type, row]
    end
    diff.should == [
      [:left, {'id' => 1, 'name' => 'Alice'}],
      [:left, {'id' => 2, 'name' => 'Bob'}]
    ]
  end

end