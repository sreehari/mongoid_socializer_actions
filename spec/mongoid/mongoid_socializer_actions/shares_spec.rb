require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mongoid::Sharer do
  describe User do
    before :each do
      @john = User.create(name: 'john')
      @jashua = User.create(name: 'jashua')
    end

    it "should have no shares" do
      [@john, @jashua].each {|u| u.shared_objects.should be_empty}
    end

    describe Photo do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
      end

      it "should have no shares" do
        [@photo1, @photo2].each { |p| p.shares.should be_empty }
      end

      it "should be sharable" do
        expect{ @john.share(@photo1) }.to change(Mongoid::Share, :count).by(1)
      end

      it "should be shared by sharer" do
        @john.share(@photo1)
        @john.shared?(@photo1).should be_true
      end

      it "should be unshared by sharer" do
        @john.share(@photo1)
        @john.unshare(@photo1)
        @john.shared?(@photo1).should be_false
      end

      it "should have the liker as sharer" do
        @john.share(@photo1)
        @photo1.sharers.should include @john
      end

      it "should not have others as sharer" do
        @photo1.sharers.should_not include @jashua
      end

      it "should be increase likes_count" do
        expect{ @jashua.share(@photo1) }.to change(@photo1, :shares_count).by(1)
      end

      it "should be shared by multiple sharers" do
        @jashua.share(@photo1)
        @john.share(@photo1)
        @photo1.sharers.should include @john, @jashua
      end

      it "should have the correct sharers count" do
        @jashua.share(@photo1)
        @john.share(@photo1)
        @photo1.shares_count.should be 2
      end

      it "should be unsharable" do
        @jashua.share(@photo1)
        @jashua.unshare(@photo1).should be_true
      end

      it "should not be unsharable by shere" do
        @jashua.unshare(@photo1).should be_false
      end

      it "should not include former liker" do
        @photo1.sharers.should_not include @jashua
      end

      it "should not be included in former likes" do
        @jashua.shared_objects.should_not include @photo1
      end
    end

    describe "get likes by model" do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
        @album1 = Album.create
        @album2 = Album.create
        @john.share(@photo1)
        @john.share(@photo2)
        @john.share(@album1)
      end

      it "should return photo likes count" do
        @john.photo_shares_count.should == 2
        @john.album_shares_count.should == 1
      end

      it "should return liked photos " do
        @john.shared_photos.should == [@photo1, @photo2]
      end
    end
  end
end