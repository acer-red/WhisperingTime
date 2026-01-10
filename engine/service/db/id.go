package db

// Legacy helpers rewritten to the new UUID-first world.

// EnsureUserID is an alias to EnsureUser for callers expecting the older name.
func GetUOIDFromUID(uid string) (string, error) { // nolint:revive
	return EnsureUser(uid)
}
