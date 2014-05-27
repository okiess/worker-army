class ExampleJob
  attr_accessor :log

  def perform(data = {})
    response_data = {foo: 'bar'}
    log.debug("in example worker with data: #{data}")
    sleep 2
    response_data
  end
end
