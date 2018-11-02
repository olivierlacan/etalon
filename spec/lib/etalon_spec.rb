require "spec_helper"

RSpec.describe Etalon do
  describe ".time" do
    let(:logic) { -> { true } }
    let(:identifier) { "Potato" }

    subject { Etalon.time(identifier, &logic) }

    context "Etalon.active? => false" do
      before { Etalon.deactivate }

      it "does nothing" do
        expect(subject).to eq(true)
        expect(Etalon.print_timings).to be_nil
      end
    end

    context "Etalon.active? => true" do
      before { Etalon.activate }

      it "returns metrics for the executed logic" do
        expect(subject).to eq(true)
        expect(Etalon.print_timings).to eq(
          {
            potato: [
              "count: 1",
              "min: 0",
              "max: 0",
              "mean: 0.0",
              "deviation: ±0%",
              "top 5: [0]"
            ]
          }
        )
      end

      it "properly increments the count" do
        expect { subject }.to change {
          Etalon.send(:instrument_store_for, key: :potato)[:count]
        }.by(1)
      end
    end
  end

  describe ".print_timings" do
    subject { Etalon.print_timings }

    context "active? => false" do
      it "returns nothing" do
        expect(subject).to be_nil
      end
    end

    context "active? => true" do
      before { Etalon.activate }

      it "returns a Hash of metrics" do
        expect(subject).to be_a Hash
      end

      context "when timings are recorded" do
        let(:logic) { -> { sleep 0.1 } }
        let(:identifier) { "Potato" }

        before { Etalon.time(identifier, &logic) }

        it "returns a Hash of metrics for the logic" do
          expect(subject).to include(:potato)
        end

        context "after 2 iterations with different timings" do
          before do
            (0.1..0.3).step(0.1).each do |duration|
              Etalon.time(identifier) { sleep duration }
            end
          end

          it "offers a non-zero standard deviation" do
            expect(subject).to include(:potato)
          end
        end
      end
    end
  end

  describe ".active?" do
    subject { Etalon.active? }

    it "defaults to false" do
      expect(subject).to be(false)
    end

    context "when ENV['ETALON_ACTIVE'] is truthy" do
      before do
        ENV['ETALON_ACTIVE'] = ""
      end

      it "is true" do
        expect(subject).to be(true)
      end
    end
  end

  describe ".activate" do
    subject { Etalon.activate }

    it "turns active? true" do
      expect { subject }.to change { Etalon.active? }.from(false).to(true)
    end
  end

  describe ".deactivate" do
    before { Etalon.activate }

    subject { Etalon.deactivate }

    it "turns active? false" do
      expect { subject }.to change { Etalon.active? }.from(true).to(false)
    end
  end

  describe ".reset_timings" do
    before do
      Etalon.activate
      Etalon.time("test") { true }
    end

    subject { Etalon.reset_timings }

    it "removes any stored timings" do
      expect { subject }.to change { Etalon.print_timings }.from(
        { test:
          [
            "count: 1",
            "min: 0",
            "max: 0",
            "mean: 0.0",
            "deviation: ±0%",
            "top 5: [0]"
          ]
        }
      ).to({})
    end
  end
end
