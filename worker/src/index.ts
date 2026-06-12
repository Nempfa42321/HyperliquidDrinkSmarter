export interface Env {
  API_DEEPSEEK_KEY: string;
  UPSTREAM_URL?: string;
}

const DEFAULT_UPSTREAM_URL = "https://llms.dotpoin.com/v1/chat/completions";
const UPSTREAM_TIMEOUT_MS = 25_000;

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }

    if (url.pathname === "/health" && request.method === "GET") {
      return json({
        ok: true,
        has_api_key: Boolean(env.API_DEEPSEEK_KEY?.trim()),
        expected_secret_name: "API_DEEPSEEK_KEY",
        upstream_url: env.UPSTREAM_URL?.trim() || DEFAULT_UPSTREAM_URL,
      });
    }

    if (url.pathname === "/chat" && request.method === "POST") {
      const key = env.API_DEEPSEEK_KEY;
      if (!key?.trim()) {
        return json({ error: "missing_api_key", message: "Missing API_DEEPSEEK_KEY secret" }, 500);
      }

      const upstreamURL = env.UPSTREAM_URL?.trim() || DEFAULT_UPSTREAM_URL;
      const body = await request.text();
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), UPSTREAM_TIMEOUT_MS);

      try {
        const upstreamResp = await fetch(upstreamURL, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${key.trim()}`,
          },
          body,
          signal: controller.signal,
        });

        const responseBody = await upstreamResp.text();

        return new Response(responseBody, {
          status: upstreamResp.status,
          headers: {
            "Content-Type": upstreamResp.headers.get("Content-Type") || "application/json",
            ...corsHeaders(),
          },
        });
      } catch (error) {
        const aborted = error instanceof Error && error.name === "AbortError";
        return json(
          {
            error: aborted ? "upstream_timeout" : "upstream_unreachable",
            message: aborted
              ? "AI provider did not respond in time. Try again."
              : "Could not reach AI provider.",
          },
          aborted ? 504 : 502,
        );
      } finally {
        clearTimeout(timeout);
      }
    }

    return json({ error: "not_found" }, 404);
  },
};

function corsHeaders(): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type,Authorization",
  };
}

function json(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...corsHeaders(),
    },
  });
}
