extends Node

signal request_response(response: Dictionary)

@onready var url = "%s/level/info" % Global.env_common_server_address

@onready var http_request = HTTPRequest.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	var client_tls_options: TLSOptions

	if Global.env_debug:
		client_tls_options = TLSOptions.client_unsafe()
	else:
		client_tls_options = TLSOptions.client()

	http_request.set_tls_options(client_tls_options)

	add_child(http_request)
	http_request.request_completed.connect(_http_request_completed)


func get_level_info(level_name: String, level_hash: int, cookie: String):
	var request_url = "%s?level=%s&hash=%s" % [url, level_name, level_hash]
	var headers = ["Content-Type: application/json", "Cookie: %s" % cookie]

	var error = http_request.request(request_url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		print("An error occurred in the HTTP request.")
		return null

	print("Sending out get request to %s" % [request_url])

	var response = await request_response
	return response


# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("HTTPRequest failed")
		request_response.emit(null)
		return

	if response_code != 200:
		print("Error in response")
		request_response.emit(null)
		return

	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	if !"error" in response or response["error"] or !"data" in response:
		print("Error or invalid response format")
		request_response.emit(null)
		return

	request_response.emit(response["data"])
