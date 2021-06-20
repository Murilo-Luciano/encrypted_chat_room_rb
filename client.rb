require 'socket'
#       KIDRSA

#2221
a = 200
b = 200
a1 = 200
b1 = 100

m = (a*b) - 1   # SECRET
e = (a1*m) + a
d = (b1*m) + b   # SECRET
n = ((e*d) - 1) / m

def encry(message, e, n)
    cryp = (message * e )%n
    return cryp
end

def decry(cryp, d, n)
    dryp = (cryp * d)%n
    return dryp
end

def ascii_msg(message)
    asc_msg = []
    message.split('').each do |c|
        asc_msg.push(c.ord)
    end
    return asc_msg
end

def un_ascii(ascii_chars)
    str_msg = []
    for c in ascii_chars
        str_msg.push((c.to_i).chr)
    end
    return str_msg
end

def ascii_char_encry(asc, e,  n)
    cryp = []
    for c in asc
        cryp.append(encry(c ,e,n))
    end
    return cryp
end

def ascii_char_decry(cryp, d, n)
    dryp = []
    (cryp.split(',')).each do |c|
        dryp.push(decry(c.to_i, d, n))
    end
    return dryp
end


server = TCPSocket.new('127.0.0.1', 3333)

server_port = server.peeraddr[1]
server_addr = server.peeraddr[2]
puts "Client on!"

#   RECEIVING AND SENDING PUBLIC Keys
sv_n = server.gets
sv_e = server.gets
cl_publickey = [n, e]
server.puts cl_publickey[0]
server.puts cl_publickey[1]



loop do
    msg_sent = gets.chomp
    
    if msg_sent == "quit"
        puts "Disconnecting"
        server.puts "quit"
        server.close
        break
    end

    # MESSAGE -> ASCII -> ENCRYPTION -> SENDING
    msg_asc = ascii_msg(msg_sent)
    msg_asc_encry = ascii_char_encry(msg_asc, sv_e.to_i, sv_n.to_i)
    server.puts (msg_asc_encry.join ',')

    # DECRYPTION -> unASCII -> MESSAGE
    msg_received = server.gets
    msg_received_unasc = un_ascii(ascii_char_decry(msg_received, d, n))
    
    if msg_received_unasc == "quit"
        server.close
        puts "Server disconnecting"
        break
    end

    puts "Server: #{msg_received_unasc.join ''}"
    
end