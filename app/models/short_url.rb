class ShortUrl < ApplicationRecord
  @persist_retries = 4
  class << self
    attr_accessor :persist_retries
  end

  validates :source, presence: true, http_url: true

  around_create :generate_unique_key

  def generate_unique_key(retries = ShortUrl.persist_retries)
    begin
      self.key = SecureRandom.urlsafe_base64(5)
    end while self.class.unscoped.exists?(key: key)

    yield
  rescue ActiveRecord::RecordNotUnique
    if retries <= 0
      raise
    else
      retries -= 1
      retry
    end
  end


end
