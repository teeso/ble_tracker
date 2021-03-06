class HomeController < ApplicationController
	def index
		output = $output

	  	if (!(session[:map].blank?))
	  		@current_map = session[:map]
		else
	  		@current_map = Map.first
	  		if @current_map.nil?
		  		Map.create(:name=>'default', :width=>800, :height=>1200)
		  		@current_map = Map.first
	  		end
	  		session[:map] = Map.find_by(name: @current_map['name'])
	  	end
	  	@current_map = Map.find_by(name: @current_map['name']) # refetch data from database to make sure latest copy


		# @message = "{\"payload\":[2,1,6,26,255,76,0,2,21,0,255,0,5,12],\"rssi\":-95,\"ble_channel\":39}"
		# @JSON_message = JSON.parse(@message)



		# Thread.new do
			# sleep(1)

			# MQTT::Client.connect('192.168.0.12',1883) do |c|
			#   # If you pass a block to the get method, then it will loop
			#   c.get('bledata') do |topic,message|
			# 		@parsedMessage ||= JSON.parse(message)
			# 		gon.watch.parsedMessage = @parsedMessage
			# 		# gon.JSON_message = @parsedMessage
			# 		# puts @parsedMessage['payload'][7]
			# 		break

			#   end
			# end
		# end

# #MOCK ONE
# 					@parsedMessage ||= JSON.parse(@message)
# 					gon.watch.parsedMessage = @parsedMessage
# 					gon.JSON_message = @parsedMessage
# #################





		# 	gon.watch.target = ["100","100"]
		# Thread.new do
		# 	sleep(1)
		# gon.watch.target = [(gon.watch.target[0].to_i+1).to_s,(gon.watch.target[1].to_i+1).to_s]
		# 	puts gon.watch.target
		# end



		



		w = params[:dimensions_width]
		h = params[:dimensions_height]
		shapes = params[:shapes]
		obstacles = params[:obstacles]
		doors = params[:doors]
		beacons = params[:beacons]
		_A = params[:A]
		_H = params[:H]
		_Q = params[:Q]
		_R = params[:R]
		# payload = @parsedMessage['payload']
	

		# payload = "{2,1,6,26,255,76,0,2,21,0,255,0,5,12}"

		# puts "-----START-------------"
		# puts $output
		# puts "--------END----------"
		

		# @runner = %x(./dist/tracker_algorithm.exe "#{w}" "#{h}" "#{shapes}" "#{obstacles}" "#{doors}" "#{beacons}" "#{_A}" "#{_H}" "#{_Q}" "#{_R}" "#{output[3]}" "#{output[2]}" "#{payload}" )

		

		# if @runner != ""
		# 	i = 0
		# 	output_x = "["
		# 	@runner.each_line do |line|
		# 		# puts line
		# 		if line.strip != ""
		# 			if i < 3
		# 				$output[i] = line.strip
		# 				i = i + 1
		# 			else
		# 				output_x += line.strip + ";"
		# 			end
		# 		end
		# 	end
		# 	$output[3] = output_x + "]"
		# end


		# gon.watch.target = [$output[0].split(),$output[1].split()]

		



  	end

  	def modify

		@maps = Map.all
	  	gon.maps = @maps
  		if (!(session[:map].blank?))
	  		@current_map = session[:map]
		else
	  		@current_map = Map.first
	  		if @current_map.nil?
		  		Map.create(:name=>'default', :width=>800, :height=>1200)
		  		@current_map = Map.first
	  		end
	  		session[:map] = Map.find_by(name: @current_map['name'])
	  	end
	  	@current_map = Map.find_by(name: @current_map['name']) # refetch data from database to make sure latest copy
	  	gon.current_map = @current_map

  		# $output = ['0','0','[0.5 0.5]','[300 400 500;10 10 10;300 400 500; 10 10 10]']
  		
  		width = params[:dimensions_width]
  		height = params[:dimensions_height]

  		if (!(width.blank?) && !(height.blank?))

	  		speed_min = 15 - 5
	  		speed_max = 15 + 5
	  		numParticles = 10


	  		$output = ['0','0'] # initialise output array; first two elem are neglible as they are never used as input

	  		output_weight = '['
	  		output_x = '['
	  		output_xdot = ';'
	   		output_y = ';'
	  		output_ydot = ';'

	  		for i in 1..numParticles
	  			output_weight += (1.0/numParticles).to_s + " " 
	  			output_x += rand(width.to_i).to_s + " "
	  			output_xdot += (rand(speed_max-speed_min)+speed_min).to_s + " " 
	  			output_y += rand(height.to_i).to_s + " "
	  			output_ydot += (rand(speed_max-speed_min)+speed_min).to_s + " " 
	  		end

	  		$output << (output_weight + "]")
	  		$output << (output_x + output_xdot + output_y + output_ydot + "]")

	  		puts $output
	  	end


	  	# Check changing maps
	  	change_map = params[:change_map]
	  	if (!(change_map.blank?))
	  		session[:map] = Map.find_by(name: change_map)

			respond_to do |format|
			  format.js {render inline: "location.reload();" }
			end
		end


	  	# Check saving updated map
	  	save_shapes = params[:save_shapes]
	  	save_beacons = params[:save_beacons]
	  	save_obstacles = params[:save_obstacles]
	  	save_doors = params[:save_doors]
	  	if (params[:update_map])
	  		puts "updating..."
	  		puts session[:map]['name']
	  		Map.find_by(name: session[:map]['name']).update(width: width, height: height, shapes: save_shapes, beacons: save_beacons, obstacles: save_obstacles, doors: save_doors)
	  	end

	  	# Check adding new map
	  	home_name = params[:new_map]
	  	home_width = params[:width]
	  	home_height = params[:height]
	  	if (!(home_name.blank?)  && !(home_width.blank?)  && !(home_height.blank?))
	  		Map.create(:name=>home_name, :width=>home_width, :height=>home_height)
	  		session[:map] = Map.find_by(name: home_name)

	  		respond_to do |format|
			  format.js {render inline: "location.reload();" }
			end
	  	end


		

	  	

	  	

  	end

  	def action_controller
  	end
end
