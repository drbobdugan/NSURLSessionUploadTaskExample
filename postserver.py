#
# A simple HTTP server that accepts POST requests to upload data to the
# server.  The contents of the file are stored in the local variable 
# "content" and discarded at the end of the POST request.
#
import sys
import signal
import time
from threading import Thread
from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler

class Handler(BaseHTTPRequestHandler):

    #
    # POST request handler
    #
    def do_POST(self):
        # Display headers
        print "POST request received headers:"
        print self.headers

        # Did we get content-length?  That means we have data to upload
        if ('Content-Length' in self.headers):
           # Get content length
           length = int(self.headers['Content-Length'])
           
           # Read upload data and store in content 
           print "START read of:",
           print length,
           print " bytes."
           content = self.rfile.read(length)
           print "END read."

           # Send response back to requester, we build response string
           # FIRST so we can compute the content-length header in the
           # response.
           #
           # NOTE: The server must compute a content-length and send this
           # in the response otherwise the client will not know when the
           # response is complete.  This is because the server and client
           # keep the connection open via keep-alive.  One alternative to
           # using content-length is to have the server close the connection
           # but this isn't as clean as it doesn't allow the client to send
           # further requests unless the client robustly handles an unexpected
           # closed connection.
           response  = "<html><head><title>POST RESPONSE</title></head>"
           response += "<body><p>The file was uploaded.</p>"
           response += "</body></html>"

           # Send response
           self.send_response(200)
           self.send_header('Content-Type', 'text/html')
           self.send_header('Content-Length', str(len(response)))
           self.end_headers()
           self.wfile.write(response)

        # Error missing content-length
        else:
           print "Handler:do_Post(): Error content-length missing from headers."
           self.send_response(411)
           self.send_header('Content-Length', 0)
           self.end_headers()
 
        return

#
# Main Program
# 
if __name__ == "__main__":

    # Specify server name OR ip address 
    # DO NOT USE localhost or 127.0.0.1
    SERVERID = 'bowsprit'

    # Specify port.
    PORT     = 42001
    
    # Start server
    print time.asctime(), "Server STARTS with id: %s port: %i.  Use <ctrl-c> to stop." % (SERVERID, PORT)
    server_address = (SERVERID, PORT)
    Handler.protocol_version='HTTP/1.1'
    httpd = HTTPServer(server_address, Handler)
    httpd.serve_forever()

    # Stop server, if we got here it's because user type <ctrl-c> in the background.
    print time.asctime(), "Server STOPS"
