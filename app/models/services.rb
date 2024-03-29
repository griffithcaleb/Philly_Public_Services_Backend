class Services

  if(ENV['DATABASE_URL'])
        uri = URI.parse(ENV['DATABASE_URL'])
        DB = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    else
        DB = PG.connect(host: "localhost", port: 5432, dbname: 'PPS_backend_development')
    end

# 1 is lat 2 is long
# credit to google for the geolocation formula 
DB.prepare("sort_by_distance",
  <<-SQL

  SELECT
name, phone_number,service_type,primary_information,physical_address,start_time,end_time,days_open,
(
   3959 *
   acos(cos(radians($1)) *
   cos(radians(lat)) *
   cos(radians(lng) -
   radians($2)) +
   sin(radians($1)) *
   sin(radians(lat )))
) AS distance
FROM services
ORDER BY distance LIMIT 100;

SQL
)




def self.all
 results = DB.exec("SELECT * FROM services;")
 results.to_json
end


def self.sort_by_distance(lat,lng)

result = DB.exec_prepared("sort_by_distance",[lat,lng])
p result
return result

end
end
