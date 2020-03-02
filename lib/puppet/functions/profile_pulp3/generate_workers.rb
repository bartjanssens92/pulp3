#
#
#
Puppet::Functions.create_function(:'profile_pulp3::generate_workers') do
  dispatch :generate do
    required_param 'Integer', :amount
  end

  def generate(amount)
    Array(1..amount)
  end

end
