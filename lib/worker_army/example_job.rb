class ExampleJob
  def perform(data = {})
    response_data = {'foo' => 'bar'}
    puts "in example worker with data: #{data}"
    sleep 2
    response_data
  end
end
