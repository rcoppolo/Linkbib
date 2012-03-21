class Link < ActiveRecord::Base
  belongs_to :user
  validates :url, :presence => true, :format => {:with => URI::regexp(%w(http https))}
  validates_uniqueness_of :url, :scope => :user_id
  
  after_validation :add_url_prefix
  
  before_save :add_display_url, :populate_title_and_description
  
  default_scope order: 'links.created_at DESC'
  
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  private
  
  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships
                      WHERE follower_id = :user_id)
    where("user_id IN (#{following_ids}) OR user_id = :user_id",
      { :user_id => user })
  end
  
  def add_url_prefix
    if self.url
      self.url = self.url.gsub(" ", "")
      self.url = "http://#{url}"  unless url.start_with?("http://","https://")
    end
  end
  
  def add_display_url
    fixed_url = self.url.gsub(/https?:\/\/(www)?\.?/, "")
    slash_index = fixed_url.index("/")
    if slash_index
      self.display_url = fixed_url[0..slash_index-1]
    else
      self.display_url = fixed_url
    end
    
  end
  
  def populate_title_and_description
    # Fill in title /description automatically on first save
    if self.new_record?
      begin
        doc = Pismo::Document.new(url)
        if doc.html_title
          self.title = doc.html_title
        else
          self.title = self.url
        end
        if doc.description
          self.description = format_description doc.description
        else
          self.description = format_description(doc.lede) if doc.lede
        end
        if doc.favicon
          self.favicon_url = doc.favicon
        else
          self.favicon_url = find_favicon
          #self.favicon_url = "/assets/globe_favicon_16x16.ico" 
        end
      rescue
        self.title = url
      end
    end
  end
  
  def find_favicon 
    self.favicon_url = "http://www.google.com/s2/favicons?domain=#{self.display_url}"
  end
  
  def format_description string
    string[0..220].split[0..-2].join(' ')
  end
end
