class Wardrobe
  attr_reader :clothes_items

  def initialize(spreadsheet_key)
    @clothes_items = []

    url = "https://spreadsheets.google.com/feeds/list/#{spreadsheet_key}/od6/public/values?alt=json"

    uri = URI(url)
    response = Net::HTTP.get(uri)

    hash = JSON.parse(response)

    array = hash["feed"]["entry"]

    array.each do |item|
      title = item["gsx$title"]["$t"]
      type = item["gsx$type"]["$t"]
      min_temp = item["gsx$min-temp"]["$t"].to_i
      max_temp = item["gsx$max-temp"]["$t"].to_i

      clothes_item = ClothesItem.new(title, type, min_temp, max_temp)

      @clothes_items << clothes_item
    end
  end

  def types
    types = @clothes_items.map(&:type)
    types.uniq
  end

  def random_suitable_items(temperature)
    items = []

    types.each do |type|
      items_of_type = @clothes_items.select do |clothes_item|
        clothes_item.type == type && clothes_item.wear?(temperature)
      end
      items << items_of_type.sample if items_of_type.any?
    end

    items
  end
end
