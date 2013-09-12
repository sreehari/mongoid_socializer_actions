require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mongoid::Follower do
  describe User do
    before :each do
      @john = User.create(name: 'john')
      @jashua = User.create(name: 'jashua')
    end

    it "should have no follows" do
      [@john, @jashua].each {|u| u.followed_objects.should be_empty}
    end

    describe Photo do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
      end

      it "should have no followers" do
        [@photo1, @photo2].each { |t| t.followers.should be_empty }
      end

      it "should be followable" do
        expect{ @john.follow(@photo1) }.to change(Mongoid::Follow, :count).by(1)
      end

      it "should be followed by follower" do
        @john.follow(@photo1)
        @photo1.reload.followed_by?(@john).should be_true
        @john.followed?(@photo1).should be_true
      end

      it "should be unfollowed by follower" do
        @john.follow(@photo1)
        @john.unfollow(@photo1)
        @photo1.reload.followed_by?(@john).should be_false
        @john.followed?(@photo1).should be_false
      end

      it "should not be followd by others" do
        @photo1.followed_by?(@jashua).should_not be_true
      end

      it "should have the followr as follower" do
        @john.follow(@photo1)
        @photo1.followers.should include @john
      end

      it "should not have others as followr" do
        @photo1.followers.should_not include @jashua
      end

      it "should be followable by multiple followrs" do
        @jashua.follow(@photo1).should be_true
        @john.follow(@photo1).should be_true
      end

      it "should be increase follows_count" do
        expect{ @jashua.follow(@photo1) }.to change(@jashua, :follows_count).by(1)
      end

      it "should be increase follows_count" do
        expect{ @jashua.follow(@photo1) }.to change(@photo1, :followers_count).by(1)
      end

      it "should be followd by multiple followrs" do
        @jashua.follow(@photo1)
        @john.follow(@photo1)
        @photo1.followers.should include @john, @jashua
      end

      it "should have the correct followers count" do
        @jashua.follow(@photo1)
        @john.follow(@photo1)
        @photo1.followers_count.should be 2
        @jashua.follows_count.should be 1
        @john.follows_count.should be 1
      end

      it "should be unlikable" do
        @jashua.follow(@photo1)
        @jashua.unfollow(@photo1).should be_true
      end

      it "should not be unlikable by unfollowr" do
        @jashua.unfollow(@photo1).should be_false
      end

      it "should not include former followr" do
        @photo1.followers.should_not include @jashua
      end

      it "should not be included in former follows" do
        @jashua.followed_objects.should_not include @photo1
      end
    end

    describe "get follows by model" do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
        @album1 = Album.create
        @album2 = Album.create
        @john.follow(@photo1)
        @john.follow(@photo2)
        @john.follow(@album1)
      end

      it "should return photo follows count" do
        @john.photo_follows_count.should == 2
        @john.album_follows_count.should == 1
      end

      it "should return followd photos " do
        @john.followed_photos.should == [@photo1, @photo2]
      end
    end
  end
end