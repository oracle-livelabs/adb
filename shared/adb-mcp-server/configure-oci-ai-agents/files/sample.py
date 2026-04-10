import os
import asyncio

from mcp.client.session_group import StreamableHttpParameters
from oci.addons.adk import Agent, AgentClient
from oci.addons.adk.mcp import MCPClientStreamableHttp
from oci.addons.adk.run.types import RequiredAction, FunctionCall, PerformedAction


async def async_input(prompt: str) -> str:
    """Non-blocking input that won't stall the async event loop."""
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, input, prompt)


async def main():
    # Retrieve bearer token from environment for security
    bearer_token = os.environ.get("MCP_BEARER_TOKEN")
    if not bearer_token:
        raise RuntimeError("Bearer token environment variable (MCP_BEARER_TOKEN) not set.")

    # Set the remote MCP server endpoint
    params = StreamableHttpParameters(
        url="your_mcp_endpoint",
        headers={
            "Authorization": f"Bearer {bearer_token}"
        }
    )

    # Create MCP client using Streamable HTTP transport
    async with MCPClientStreamableHttp(
        params=params,
        name="Streamable MCP Server"
    ) as mcp_client:

        # Set up AgentClient
        client = AgentClient(
            auth_type="api_key",
            profile="DEFAULT",
            region="us-chicago-1"
        )

        # Replace with your real Agent Endpoint OCID below
        agent_endpoint_id = "your_agent_ocid"

        class InteractiveAgent(Agent):
            async def _handle_required_actions(
                self,
                response,
                on_fulfilled_required_action=None,
            ):
                required_actions = response.get("required_actions", [])
                performed_actions = []

                for action in required_actions:
                    required_action = RequiredAction.model_validate(action)

                    if required_action.required_action_type == "FUNCTION_CALLING_REQUIRED_ACTION":
                        function_call = required_action.function_call
                        print(f"Proposed tool: {function_call.name}")
                        print(f"With arguments: {function_call.arguments}")

                        # ✅ Use async_input instead of blocking input()
                        confirm = (await async_input("Should I execute this tool? (yes/no): ")).strip().lower()

                        if confirm == 'yes':
                            performed_action = await self._execute_function_call(
                                function_call, required_action.action_id
                            )
                            if performed_action:
                                performed_actions.append(performed_action)
                            if on_fulfilled_required_action:
                                on_fulfilled_required_action(required_action, performed_action)
                        else:
                            print("Skipping tool execution.")
                            performed_actions.append(
                                PerformedAction(
                                    action_id=required_action.action_id,
                                    performed_action_type="FUNCTION_CALLING_PERFORMED_ACTION",
                                    function_call_output="User denied execution."
                                )
                            )

                return performed_actions

        agent = InteractiveAgent(
            client=client,
            agent_endpoint_id=agent_endpoint_id,
            instructions="Use the tools to answer the questions.",
            tools=[await mcp_client.as_toolkit()]
        )
        agent.setup()
        print("Setup complete — ADB MCP tools registered with agent.")

        # ✅ Interactive bot loop using async_input
        while True:
            query = (await async_input("\nEnter your question (or 'quit' to exit): ")).strip()
            if query.lower() == 'quit':
                break
            if query:
                print(f"\nQuery: {query}")
                response = await agent.run_async(query)
                response.pretty_print()


if __name__ == "__main__":
    asyncio.run(main())