require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mongoid::Liker do
  describe User do
    before :each do
      @john = User.create(name: 'john')
      @jashua = User.create(name: 'jashua')
    end

    it "should have no likes" do
      [@john, @jashua].each {|u| u.liked_objects.should be_empty}
    end

    describe Photo do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
      end

      it "should have no likers" do
        [@photo1, @photo2].each { |t| t.likers.should be_empty }
      end

      it "should be likeable" do
        expect{ @john.like(@photo1) }.to change(Mongoid::Like, :count).by(1)
      end

      it "should be liked by liker" do
        @john.like(@photo1)
        @photo1.reload.liked_by?(@john).should be_true
        @john.liked?(@photo1).should be_true
      end

      it "should be unliked by liker" do
        @john.like(@photo1)
        @john.unlike(@photo1)
        @photo1.reload.liked_by?(@john).should be_false
        @john.liked?(@photo1).should be_false
      end

      it "should not be liked by others" do
        @photo1.liked_by?(@jashua).should_not be_true
      end

      it "should have the liker as liker" do
        @john.like(@photo1)
        @photo1.likers.should include @john
      end

      it "should not have others as liker" do
        @photo1.likers.should_not include @jashua
      end

      it "should be likeable by multiple likers" do
        @jashua.like(@photo1).should be_true
        @john.like(@photo1).should be_true
      end

      it "should be increase likes_count" do
        expect{ @jashua.like(@photo1) }.to change(@jashua, :likes_count).by(1)
      end

      it "should be increase likes_count" do
        expect{ @jashua.like(@photo1) }.to change(@photo1, :likers_count).by(1)
      end

      it "should be liked by multiple likers" do
        @jashua.like(@photo1)
        @john.like(@photo1)
        @photo1.likers.should include @john, @jashua
      end

      it "should have the correct likers count" do
        @jashua.like(@photo1)
        @john.like(@photo1)
        @photo1.likers_count.should be 2
        @jashua.likes_count.should be 1
        @john.likes_count.should be 1
      end

      it "should be unlikable" do
        @jashua.like(@photo1)
        @jashua.unlike(@photo1).should be_true
      end

      it "should not be unlikable by unliker" do
        @jashua.unlike(@photo1).should be_false
      end

      it "should not include former liker" do
        @photo1.likers.should_not include @jashua
      end

      it "should not be included in former likes" do
        @jashua.liked_objects.should_not include @photo1
      end
    end

    describe "get likes by model" do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
        @album1 = Album.create
        @album2 = Album.create
        @john.like(@photo1)
        @john.like(@photo2)
        @john.like(@album1)
      end

      it "should return photo likes count" do
        @john.photo_likes_count.should == 2
        @john.album_likes_count.should == 1
      end

      it "should return liked photos " do
        @john.liked_photos.should == [@photo1, @photo2]
      end
    end
  end
end