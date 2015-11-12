require 'spec_helper'

describe RankingCalculator do
  let(:last_total_tweets) { 0 }
  let(:cumulative_total_tweets) { 0 }
  let(:count_consecutive_days) { 1 }
  let(:trend_direction) { 0 }  

  let(:record) { double("Record", last_total_tweets: last_total_tweets, cumulative_total_tweets: cumulative_total_tweets, count_consecutive_days: count_consecutive_days, trend_direction: trend_direction) } 
  
  describe '#rank' do
    subject { described_class.rank(record) }
    
    it { is_expected.to eq 0}

    it 'is a sum of the last_total_tweets_score and the cumulative_total_tweets_score' do
      expect(described_class).to receive(:score_last_day_activity).and_return 1 
      expect(described_class).to receive(:score_cumulative_activity).and_return 1 
      expect(described_class).to receive(:score_trend_direction).and_return 1 
      expect(subject).to eq 3
    end
    
    describe 'max score (1000)' do
      let(:last_total_tweets) { 5000 }
      let(:cumulative_total_tweets) { 30000 }
      let(:count_consecutive_days) { 1 }
      let(:trend_direction) { 1500 }
      it { is_expected.to eq 1000 }
    end

    describe 'decay over time' do
      let(:last_total_tweets) { 5000 }
      let(:cumulative_total_tweets) { 30000 }
      let(:count_consecutive_days) { 1 }
      let(:trend_direction) { 1500 }

      context 'on the first day' do
        it { is_expected.to eq 1000 }
      end
      context 'after 2 consecutive days' do
        let(:count_consecutive_days) { 2 }
        it { is_expected.to eq  834 }
      end
      context 'after 3 consecutive days' do
        let(:count_consecutive_days) { 3 }
        it { is_expected.to eq  667 }
      end
      context 'after 4 consecutive days' do
        let(:count_consecutive_days) { 4 }
        it { is_expected.to eq  501 }
      end
      context 'after 5 consecutive days' do
        let(:count_consecutive_days) { 5 }
        it { is_expected.to eq  334 }
      end
      context 'after 6 consecutive days' do
        let(:count_consecutive_days) { 6 }
        it { is_expected.to eq  167 }
      end
      context 'after 7 consecutive days' do
        let(:count_consecutive_days) { 7 }
        it { is_expected.to eq  1 }
      end
    end
  end
  
  describe '#score_last_day_activity' do
    subject { described_class.score_last_day_activity(record) }
    
    context 'when cumulative_total_tweets is more than 30000' do
      let(:last_total_tweets) { 6000 }
      it 'returns a maximum value of 500' do
        expect(subject).to eq 500 
      end
    end
    context 'when there are a lot of tweets' do
      let(:last_total_tweets) { 4000 }
      it 'returns a high number' do
        expect(subject).to eq 400 
      end
    end
    context 'when there are very few tweets' do
      let(:last_total_tweets) { 750 }
      it 'returns a low number' do
        expect(subject).to eq 75 
      end
    end
    context 'when there are very very few tweets' do
      let(:last_total_tweets) { 100 }
      it 'returns a low number' do
        expect(subject).to eq 10 
      end
    end
  end
  
  describe '#score_cumulative_total_tweets' do
    subject { described_class.score_cumulative_activity(record) }
    
    context 'when cumulative_total_tweets is more than 30000' do
      let(:cumulative_total_tweets) { 50000 }
      it 'returns a maximum value of 250' do
        expect(subject).to eq 250 
      end
    end
    context 'when there are a lot of cumulative tweets' do
      let(:cumulative_total_tweets) { 20000 }
      it 'returns a high number' do
        expect(subject).to eq 166 
      end
    end
    context 'when there are very few cumulative tweets' do
      let(:cumulative_total_tweets) { 750 }
      it 'returns a low number' do
        expect(subject).to eq 6 
      end
    end
  end
  
  describe '#score_trend_direction' do
    subject { described_class.score_trend_direction(record) }
    context 'when trend_direction is more than 1500' do
      let(:trend_direction) { 2000 }
      it 'returns a maximum value of 250' do
        expect(subject).to eq 250 
      end
    end
    context 'when trending up' do
      let(:trend_direction) { 750 }
      it 'returns a positive score' do
        expect(subject).to eq 125 
      end
    end
    context 'when trending down' do
      let(:trend_direction) { -750 }
      it 'returns a negative score' do
        expect(subject).to eq -125 
      end
    end
  end
  
end


