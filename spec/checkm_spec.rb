require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "checkm" do
  it "should be valid if empty" do
    checkm = ''
    res = Checkm::Manifest.new(checkm)
    res.entries.should be_empty
    res.should be_valid
  end

  it "should ignore comments" do
    checkm = '#'
    res = Checkm::Manifest.new(checkm)
    res.entries.should be_empty
    res.should be_valid
  end

  it "should new the checkm version" do
    checkm = '#%checkm_0.7'
    res = Checkm::Manifest.new(checkm)
    res.entries.should be_empty
    res.should be_valid
    res.version.should == '0.7'
  end

  describe "simple checkm line" do 
    before(:each) do 
      @checkm = 'book/Chapter9.xml |   md5   |  49afbd86a1ca9f34b677a3f09655eae9'
      @result = Checkm::Manifest.new(@checkm)
      @line = @result.entries.first
    end

    it "should new one entry" do
      @result.should have(1).entries
    end

    it "should new a checkm line" do 
      @line.values[0].should == 'book/Chapter9.xml'
      @line.values[1].should == 'md5'
      @line.values[2].should == '49afbd86a1ca9f34b677a3f09655eae9'
    end 

    it "should allow name-based lookups" do
      @line.sourcefileorurl.should == 'book/Chapter9.xml'
      @line.alg.should == 'md5'
      @line.digest.should == '49afbd86a1ca9f34b677a3f09655eae9'
    end
  end

  it "should support custom field names", :blah => true do
    checkm= '#%fields | testa | test b' + "\n" +
            'book/Chapter9.xml |   md5   |  49afbd86a1ca9f34b677a3f09655eae9'
    res = Checkm::Manifest.new(checkm)

    line = res.entries.first

    line.sourcefileorurl.should ==  'book/Chapter9.xml'
    line.testa.should == 'book/Chapter9.xml'
    line.alg.should == 'md5'
    line.send(:'test b').should == 'md5'
    line.digest.should == '49afbd86a1ca9f34b677a3f09655eae9'
  end

  describe "validity check" do
    it "should be valid if the file exists" do
      checkm = '1 | md5 | b026324c6904b2a9cb4b88d6d61c81d1'
      res = Checkm::Manifest.new(checkm, :path => File.join(File.dirname(__FILE__), 'fixtures/test_1'))
      res.should have(1).entries
      res.should be_valid
    end

    it "should be valid if the directory exists" do
      checkm = 'test_1 | dir'
      res = Checkm::Manifest.new(checkm, :path => File.join(File.dirname(__FILE__), 'fixtures'))
      res.should have(1).entries
      res.should be_valid
    end

    it "should be invalid if a file is missing" do
      checkm = '2 | md5 | b026324c6904b2a9cb4b88d6d61c81d1'
      res = Checkm::Manifest.new(checkm, :path => File.join(File.dirname(__FILE__), 'fixtures/test_1'))
      res.should have(1).entries
      res.should_not be_valid
    end

    it "should be invalid if the checksum is different" do
      checkm = '1 | md5 | zzz'
      res = Checkm::Manifest.new(checkm, :path => File.join(File.dirname(__FILE__), 'fixtures/test_1'))
      res.should have(1).entries
      res.should_not be_valid
    end
  end

  describe "manipulate manifest" do
    it "should support simple create" do
      res = Checkm::Entry.create('LICENSE.txt')
      res.to_s.should match( /LICENSE\.txt | md5 | 927368f89ca84dbec878a8d017f06443 | 1054 | \d{4}/)
    end

    it "should allow files to be added to an existing manifest" do
      m = Checkm::Manifest.new('')
      m.add('LICENSE.txt')
      m.should have(1).entries
      m.should be_valid
    end
  end

  it "should be serializable to a string" do
    m = Checkm::Manifest.new('')
    m.add('LICENSE.txt')
    lines = m.to_s.split "\n"
    lines[0].should == '#%checkm_0.7'
    lines[1].should match(/^LICENSE\.txt/)
  end
end

