module Methods
	def set_bucket(bucket_name)
		@bucket = @client.bucket(bucket_name)
	end
end

ActiveStorage::Service.module_eval { attr_writer :bucket }
ActiveStorage::Service.class_eval { include Methods }