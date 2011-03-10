package edu.pitt.math.jhol.irc;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.InetAddress;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import org.apache.commons.daemon.Daemon;
import org.apache.commons.daemon.DaemonContext;
import org.apache.commons.daemon.DaemonInitException;
import org.jibble.pircbot.PircBot;

import bsh.EvalError;


public class HOLDaemon extends PircBot implements Daemon, Runnable {

	// private String owner;
	// private Interpreter interpreter;
	private ProcessBuilder pb;
	private Process proc;
	private BufferedWriter bin;
	private BufferedReader bout;
	private int holPid;
	private ProcessBuilder interrupt;
	private String homeChannel;
	private ExecutorService es;
	private String server;
	private String channel;
	private boolean sleeping;

	public HOLDaemon() throws Exception {
		// interpreter = new Interpreter();
		// interpreter.set("bot", this);
		this.setName(InetAddress.getLocalHost().getHostName());

		List<String> command = new ArrayList<String>();

		homeChannel = "#hol";
		// channel = "#hol";

		command.add("hol_light");
		ProcessBuilder pb = new ProcessBuilder(command);
		pb.redirectErrorStream(true);
		

		es = Executors.newSingleThreadExecutor();

		this.setMessageDelay(0);// So we can output at fast rates
		this.setVerbose(true);// DEBUG

		holPid = 0;
		interrupt = null;
	}

	protected void write(String s) throws IOException {
		bin.write(s);
	}

	protected void flush() throws IOException {
		bin.flush();
	}

	public boolean ready() throws IOException {
		return bout.ready();
	}

	protected int read() throws IOException {

		return bout.read();
	}

	protected void onMessage(String channel, String sender, String login, String hostname, String message){





		if (message.startsWith(this.getNick()) || message.startsWith("all")){



			//If we have been addressed
			int pos = message.indexOf(' ');
			message = message.substring(pos).trim();

			if (sleeping){
				if (message.startsWith("sleep")){
					sendMessage(channel, "Hibernating.");
				
				}
				if (message.startsWith("wake")){
					sleeping = false;
					sendMessage(channel, "Sentry mode activated.");
					
				}
			}else{

				if (message.startsWith("sleep")){
					sleeping = true;
					sendMessage(channel, "Sleep mode activated. (do '" + this.getNick() + " wake' to wake)");
					
				}
				if (message.startsWith("wake")){
					sleeping = false;
					sendMessage(channel, "Canvassing.");
					
				}

				//If this is the active channel[ and is an eval command
				if (message.startsWith("eval")){
					if (this.channel == null || this.channel.equals(channel)){
						pos = message.indexOf(' ');
						message = message.substring(pos).trim() + "\n";
						try {
							write(message);
							flush();
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}

					}else{
						this.sendMessage(channel, sender + " sorry but I am currently listening in " + this.channel);
					}
				}


				if (message.startsWith("help")){
					this.sendMessage(channel, sender + ", I am " + this.getNick() + ", a HOL Light toplevel bot");
					this.sendMessage(channel, "you can instruct me with the following commands:");
					this.sendMessage(channel, "eval       evaluate hol command");
					this.sendMessage(channel, "help       print help message");
					this.sendMessage(channel, "restart    restart the toplevel");
					this.sendMessage(channel, "sleep      go to sleep");
					this.sendMessage(channel, "wake       wake me up from sleep");
					this.sendMessage(channel, "interrupt  interrupt the toplevel");
					
					
				}
				if (message.startsWith("restart")){

				}
				if (message.startsWith("update")){
					
				}

				if (message.startsWith("interrupt")){
					try {
						interrupt.start();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
				}


			}


		}
	}

		protected String readLine() throws IOException {

			return bout.readLine();
		}

		/*
		 * public String setOwner(String owner){ return this.owner = owner; }
		 * 
		 * public void message(String message){ this.sendMessage(owner, message); }
		 */

		/**
		 * @param args
		 * @throws EvalError
		 */
		/*
		 * public static void main(String[] args) throws EvalError { HOLDaemon bot =
		 * new HOLDaemon();
		 * 
		 * bot.setVerbose(true);
		 * 
		 * 
		 * 
		 * //server,channel,owner
		 * 
		 * BufferedReader in = new BufferedReader(new InputStreamReader(System.in));
		 * 
		 * bot.setMessageDelay(0);
		 * 
		 * 
		 * while(true){ try { bot.interpreter.eval( in.readLine()); } catch
		 * (IOException e) { // TODO Auto-generated catch block e.printStackTrace();
		 * }
		 * 
		 * 
		 * }
		 * 
		 * }
		 */

		@Override
		public void destroy() {
			// TODO Auto-generated method stub
			es.shutdown();
			
		}

		@Override
		public void init(DaemonContext arg0) throws DaemonInitException, Exception {
			// Config stuff goes here
			String[] args = arg0.getArguments();
			server = args[0];
			if (server == null || server.length() == 0)
				server = "charizard.zapto.org";
		}

		@Override
		public void start() throws Exception {
			// TODO Auto-generated method stub

			proc = pb.start();
			bin = new BufferedWriter(new OutputStreamWriter(proc.getOutputStream()));
			bout = new BufferedReader(new InputStreamReader(proc.getInputStream()));
			
			this.connect(server);
			es.submit(this);
		}

		@Override
		public void stop() throws Exception {
			// TODO Auto-generated method stub
			this.disconnect();
			
			proc.destroy();
			
		}

		@Override
		public void run() {
			String line = "";
			while (line != null) {
				try {
					line = bout.readLine();
					line = line.substring(1).trim();
					this.sendMessage(channel, line);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}

	}