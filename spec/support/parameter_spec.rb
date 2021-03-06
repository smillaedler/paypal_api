require "rails/all"
require "spec_helper"

describe Paypal::Api::Parameter do
	before do
		@api = Paypal::Api
	end

	describe Paypal::Api::Enum do
		it "should only allow enumerated input" do
			param = @api::Enum.new("first", "second", "third")

			param.parse("first").should eq("first")
			param.parse("second").should eq("second")
			param.parse("third").should eq("third")

			expect {
				param.parse("anything else")
			}.to raise_exception(Paypal::InvalidParameter)
		end

		it "should allow lookup on normalized matching" do
			param = @api::Enum.new("This", "FirstTest", "SaweetDude")

			param.parse(:this).should eq("This")
			param.parse(:first_test).should eq("FirstTest")
			param.parse(:saweet_dude).should eq("SaweetDude")
		end

		describe "hash enumerations" do
			before(:each) do
				@param = @api::Enum.new({:thing => "OK", :that => "TEO"})
			end

			it "should allow symbols to have formatted values as output" do
				@param.parse(:thing).should eq("OK")
				@param.parse(:that).should eq("TEO")
			end

			it "should not respond to symbols that aren't in the hash" do
				expect {
					@param.parse("anything_else")
				}.to raise_exception(Paypal::InvalidParameter)
			end

			it "should know it's a hash enumeration" do
				@param.instance_variable_get("@hash_enum").should be_true
			end
		end

		it "should coerce symbols to strings" do
			param = @api::Enum.new("First", "Second", "ThirdThing")

			param.parse(:first).should eq("First")
			param.parse(:second).should eq("Second")
			param.parse(:third_thing).should eq("ThirdThing")

			expect {
				param.parse(:anything_else)
			}.to raise_exception(Paypal::InvalidParameter)
		end
	end

	describe Paypal::Api::Coerce do
		it "should allow a well formed coercion" do
			param = @api::Coerce.new( lambda { |val| return [1, "1", true].include?(val) ? 1 : 0 } )

			param.parse(1).should eq(1)
			param.parse("1").should eq(1)
			param.parse(true).should eq(1)

			param.parse(23).should eq(0)
			param.parse("adfa").should eq(0)
		end
	end

	describe Paypal::Api::Sequential do
		before do
			class Testical < @api
				set_request_signature :tester, {
					:sequential => @api::Sequential.new({:l_string => String, :l_fixnum => Fixnum, :l_set_category => Optional.new(String)})
				}
			end

			@request = Testical.tester
			@request.sequential.push({:l_string => "sasdf", :l_fixnum => 23, :l_set_category => "asdfasdf"})


			expect {
				@request.sequential.push({:l_string => "sass"})
			}.to raise_exception Paypal::InvalidParameter

			expect {
				@request.sequential.push({:l_string => "sass", :l_fixnum => "string"})
			}.to raise_exception Paypal::InvalidParameter
		end

		it "should allow nestedly defined params" do
			@request.sequentials_string.should include("sasdf")
			@request.sequentials_string.should include("23")
		end

		it "should allow optional params" do
			@request.sequential.push({:l_string => "alf", :l_fixnum => 22})
			@request.sequentials_string.should_not include("L_SETCATEGORY1")
		end

		it "should number the items" do
			@request.sequential.push({:l_string => "alf", :l_fixnum => 22})
			@request.sequentials_string.should include("L_FIXNUM1")
			@request.sequentials_string.should include("L_SETCATEGORY0")
		end

		it "should keep the first underscore" do
			param = @api::Sequential.new({:l_test => String})
			param.to_key(:l_test, 0).should eq("L_TEST0")
			param.to_key(:l_set_category, 1).should eq("L_SETCATEGORY1")
		end

		it "should allow a list length limit to be set" do
			expect {
				param = @api::Sequential.new({:l_test => String}, 2)
			}.to_not raise_exception
		end

		it "should raise an InvalidParameter exception when more than the limit is pushed" do
			param = @api::Sequential.new({:test => String}, 2)
			param.push(:test => "ok")
			param.push(:test => "asdf")

			expect {
				param.push(:test => "asdfasdf")
			}.to raise_exception(Paypal::InvalidParameter)
		end

		describe "when a to_key proc is provided" do
			it "should use the proc to output keys" do
				@lambda = lambda {|key, i|
					"someThing#{i}.#{key}"
				}
				param = @api::Sequential.new({:test => String}, 2, @lambda)
				param.push(:test => "ok")
				param.push(:test => "asdf")

				param.to_query_string.should eq("&someThing0.test=ok&someThing1.test=asdf")
			end
		end
	end

	describe Paypal::Api::Hash do

	end

	describe Paypal::Api::Optional do

		it "should allow optional enum" do
			param = @api::Optional.new(@api::Enum.new("test", "tamp"))

			expect {
				param.parse("tisk")
			}.to raise_exception(Paypal::InvalidParameter)

			param.parse("test").should eq("test")
		end

		it "should allow optional regexp" do
			param = @api::Optional.new(/test/)

			expect {
				param.parse("tisk")
			}.to raise_exception(Paypal::InvalidParameter)

			param.parse("test").should eq("test")
			param.parse(" sdf a test").should eq("test")
		end

		it "should allow optional class specifiers" do
			param = @api::Optional.new(String)

			expect {
				param.parse(2)
			}.to raise_exception(Paypal::InvalidParameter)

			param.parse("test").should eq("test")
			param.parse(" sdf a test").should eq(" sdf a test")
		end

		it "should allow a hash specifier"

		describe "when hash specifier provided" do
			it "should still be allowed to have optional within"

			it "should validate required fields"

			it "should dot the fields together somehow?"
		end
	end
end