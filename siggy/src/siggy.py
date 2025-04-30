#!/usr/bin/env python

from typing import Never

import socket
import sys
import subprocess
import Pyro5.api
import Pyro5.core
import Pyro5.server
from contextlib import closing
import click

from collections import defaultdict


ListenerPort = int
ChannelName = str


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


@Pyro5.server.expose
@Pyro5.server.behavior(instance_mode="single")
class SiggyDaemonRPC:
    channels: dict[ChannelName, list[Pyro5.api.Proxy]]

    def __init__(self):
        self.channels = defaultdict(list)

    def register(self, channel: ChannelName, port: ListenerPort):
        client = Pyro5.api.Proxy(f"PYRO:siggy.listener@localhost:{port}")
        self.channels[channel].append(client)

    def send(self, channel: ChannelName, message: str):
        for i, client in enumerate(self.channels[channel].copy()):
            try:
                client.handle(message)
            except Pyro5.errors.ConnectionClosedError as e:
                eprint(f"ERROR: client {client} failed handling message {message}; connection was closed", exc_info=e)
                del self.channels[channel][i]
            except Pyro5.errors.TimeoutError as e:
                eprint(f"ERROR: client {client} failed handling message {message}; timeout", exc_info=e)
                del self.channels[channel][i]
            except Exception as e:
                eprint(f"ERROR: client {client} failed handling message {message}; unknown error", exc_info=e)


class SiggyDaemon:
    port: int

    def __init__(self, port: int):
        self.port = port

    def start(self):
        Pyro5.server.serve(
            {SiggyDaemonRPC: "siggy.daemon"}, host="localhost", port=self.port
        )


@Pyro5.server.expose
@Pyro5.server.behavior(instance_mode="single")
class SiggyListenerRPC:
    channel: ChannelName
    placeholder: str | None
    command: list[str]

    def __init__(self, channel: ChannelName, placeholder: str | None, command: list[str]):
        self.channel = channel
        self.placeholder = placeholder
        self.command = command

    def handle(self, message: str):
        command = self.command
        if self.placeholder is not None:
            for i, elem in enumerate(command.copy()):
                if self.placeholder in elem:
                    command[i] = elem.format(message)
        else:
            command.append(message)
        subprocess.run(command, check=False, stderr=None, stdout=None)


def find_free_port():
    with closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
        s.bind(("", 0))
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        return s.getsockname()[1]


class SiggyReceiver:
    port: int
    channel: ChannelName
    placeholder: str | None
    command: list[str]

    def __init__(
        self, port: int, channel: ChannelName, placeholder: str | None, command: list[str]
    ):
        self.port = port
        self.channel = channel
        self.placeholder = placeholder
        self.command = command

    def start(self):
        listener = SiggyListenerRPC(self.channel, self.placeholder, self.command)

        port = find_free_port()

        nameserver = Pyro5.api.locate_ns()
        uri = nameserver.lookup("siggy.daemon")
        print(f"uri: {uri}")

        client = Pyro5.api.Proxy(uri)
        client.register(self.channel, port)

        Pyro5.server.serve(
            {listener: "siggy.listener"}, host="localhost", port=port
        )


class SiggySender:
    port: int
    channel: ChannelName
    message: str

    def __init__(self, port: int, channel: ChannelName, message: str):
        self.port = port
        self.channel = channel
        self.message = message

    def send(self):
        client = Pyro5.api.Proxy(f"PYRO:siggy.daemon@localhost:{self.port}")
        client.send(self.channel, self.message)


def invalid_parameter(message: str) -> Never:
    eprint(f"ERROR: {message}")
    exit(1)


@click.command()
@click.option(
    "--daemon",
    "-d",
    is_flag=True,
    help="start the server; you usually only need one of these; siggy doesn't work without one",
)
@click.option("--receive", "-r", is_flag=True, help="listen for messages")
@click.option("--send", "-s", type=str, help="provide a message to send")
@click.option("--channel", "-c", type=str, help="a named channel")
@click.option("--port", "-p", type=int, default=31337, help="listen for messages")
@click.option(
    "--placeholder",
    "-I",
    type=str,
    default="{}",
    help="a string to use to substitute the received content; when not provided, content is provided is the last content",
)
@click.argument("command", nargs=-1)
def siggy(
    daemon: bool,
    receive: bool,
    send: str | None,
    channel: str | None,
    port: int,
    placeholder: str | None,
    command: list[str] | None,
):
    if daemon:
        if receive:
            invalid_parameter("`--receive` not expected with `--daemon`")
        if send is not None:
            invalid_parameter("`--send` not expected with `--daemon`")
        if channel is not None:
            eprint("WARNING: `--channel` not expected with `--daemon` - ignoring this")
        if placeholder is not None:
            eprint("WARNING: `--placeholder` not expected with `--daemon` - ignoring this")
        if command is not None and len(command) > 0:
            eprint(
                "WARNING: ignoring positional arguments; those are used to provide a command for receives - ignoring this"
            )
        SiggyDaemon(port).start()

    if receive:
        if daemon:
            invalid_parameter("`--daemon` not expected with `--receive`")
        if send is not None:
            invalid_parameter("`--send` not expected with `--receive`")
        if channel is None:
            invalid_parameter("`--channel` is required for `--receive`")
        if command is None or len(command) == 0:
            eprint("WARNING: falling back to `echo` as default command")
            command = ["echo"]
            placeholder = None
        SiggyReceiver(port, channel, placeholder, command).start()

    if send is not None:
        if daemon:
            invalid_parameter("`--daemon` not expected with `--send`")
        if receive:
            invalid_parameter("`--send` not expected with `--send`")
        if channel is None:
            invalid_parameter("`--channel` is required for `--send`")
        if placeholder is not None:
            eprint("WARNING: `--placeholder` not expected with `--send` - ignoring this")
        if command is not None and len(command) > 0:
            eprint(
                "WARNING: ignoring positional arguments; those are used to provide a command for receives - ignoring this"
            )
        message = send
        SiggySender(port, channel, message).send()

    invalid_parameter("you must either send/receive or start the daemon")


if __name__ == "__main__":
    siggy()
