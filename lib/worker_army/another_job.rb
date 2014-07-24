class AnotherJob
  attr_accessor :log

  def perform(data = {})
    response_data = {foo2: 'bar2'}
    log.debug("in another job with data: #{data}")
    sleep 2
    response_data
  end
end
