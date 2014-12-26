require 'spec_helper'

describe Hijiri do
  it 'has a version number' do
    expect(Hijiri::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(Hijiri.parse('nyan')).to be_an_instance_of(Hijiri::Parser)
  end
end
