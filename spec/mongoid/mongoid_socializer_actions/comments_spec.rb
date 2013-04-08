require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Mongoid::Commenter do
  describe User do
    before :each do
      @john = User.create(name: 'john')
      @jashua = User.create(name: 'jashua')
    end

    describe Photo do
      before :each do
        @photo1 = Photo.create
        @photo2 = Photo.create
      end

      it "should have no comments" do
        [@photo1, @photo2].each { |t| t.comments.should be_empty }
      end

      it "should be commentable" do
        expect{ @john.comment_on(@photo1, "Beautiful") }.to change(Mongoid::Comment, :count).by(1)
      end

      it "comment body should not be empty" do
        comment = @john.comment_on(@photo1, '')
        comment.errors.present?.should be_true
        comment.errors[:body].should == ["can't be blank"]
        comment.persisted?.should be_false
      end

      it "should be commented by commenter" do
        @john.comment_on(@photo1, 'Beautiful')
        @photo1.commenters.should include @john
      end

      it "should not be commented by others" do
        @photo1.commenters.should_not include @john
      end

      it "should be commentable by multiple likers" do
        expect do
          @jashua.comment_on(@photo1, 'Beautiful')
          @john.comment_on(@photo1, 'Not Beautiful')
        end.to change { Mongoid::Comment.count }.by(2)
      end

      it "should be increase comments_count" do
        expect{ @jashua.comment_on(@photo1, 'Beautiful') }.to change(@photo1, :comments_count).by(1)
      end

      it "should be increase comments_count" do
        expect{ @jashua.comment_on(@photo1, 'Beautiful') }.to change(@jashua, :comments_count).by(1)
      end

      it "should have the correct comments count" do
        @jashua.comment_on(@photo1, 'test1')
        @john.comment_on(@photo1, 'test2')
        @photo1.comments_count.should be 2
        @jashua.comments_count.should be 1
        @john.comments_count.should be 1
      end

      it "should be uncommentable" do
        comment = @jashua.comment_on(@photo1, 'Beautiful')
        expect{ @jashua.delete_comment(comment) }.to change { Mongoid::Comment.count }.by(-1)
      end

      it "edit comment" do
        comment = @jashua.comment_on(@photo1, 'Beautiful')
        expect{ @jashua.edit_comment(comment, 'Not Beautiful') }.to change { comment.reload.body }.from('Beautiful').to('Not Beautiful')
      end
    end

    describe "get comment by model" do
      before :each do
        @photo1 = Photo.create
        @c1 = @john.comment_on(@photo1, "Beautiful")
        @c2 = @jashua.comment_on(@photo1, "Excellemt")
      end

      it "should return photo comments" do
        @john.comments_of(@photo1).should include @c1, @c2
      end

      it "return comments with eager loaded commenters" do
        @photo1.comments_with_eager_loaded_commenter.should include @c1, @c2
      end
    end
  end
end