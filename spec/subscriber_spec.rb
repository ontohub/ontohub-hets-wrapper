# frozen_string_literal: true

require 'spec_helper'

describe HetsAgent::Subscriber do
  let(:bunny_spy) { :bunny_spy }
  subject { HetsAgent::Subscriber.new }

  context 'hets_version' do
    let(:version_timestamp) { 1_471_209_385 }
    let(:version) { "v0.99, #{version_timestamp}" }
    before do
      allow(Bunny).to receive(:new).and_return(bunny_spy)
      allow(subject).
        to receive(:call_hets_version).and_return(version)
    end

    it 'parses the version correctly' do
      expect(subject.hets_version).to eq(version_timestamp)
    end

    context 'unreachable hets' do
      before do
        allow(subject).
          to receive(:call_hets_version).and_raise(Errno::ECONNREFUSED)
      end

      it 'raises the correct error on unreachable hets' do
        expect { subject.hets_version }.
          to raise_error(HetsAgent::HetsUnreachableError,
                         'Hets unreachable')
      end
    end

    context 'could not parse hets version' do
      before do
        allow(subject).
          to receive(:call_hets_version).and_return('I am not a version')
      end

      it 'raises the correct error on unparseable version' do
        expect { subject.hets_version }.
          to raise_error(HetsAgent::HetsVersionParsingError,
                         'Could not parse Hets version')
      end
    end
  end
end
