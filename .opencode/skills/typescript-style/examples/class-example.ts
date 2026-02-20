/**
 * @fileoverview Example TypeScript class demonstrating Google style guide best practices.
 */

/**
 * Represents a user in the system.
 */
export interface User {
  id: string;
  name: string;
  email: string;
  isActive: boolean;
  createdAt: Date;
}

/**
 * Options for creating a user service.
 */
export interface UserServiceOptions {
  cacheEnabled?: boolean;
  maxRetries?: number;
}

/**
 * Service for managing user data with proper TypeScript styling.
 */
export class UserService {
  private readonly cache = new Map<string, User>();
  private readonly maxRetries: number;

  /**
   * Creates a new UserService instance.
   * @param apiUrl The base URL for the API
   * @param options Optional configuration
   */
  constructor(
    private readonly apiUrl: string,
    options: UserServiceOptions = {}
  ) {
    this.maxRetries = options.maxRetries ?? 3;
  }

  /**
   * Retrieves a user by ID.
   * @param id The user ID to fetch
   * @returns The user if found, undefined otherwise
   */
  async getUser(id: string): Promise<User | undefined> {
    // Check cache first
    const cached = this.cache.get(id);
    if (cached !== undefined) {
      return cached;
    }

    // Fetch from API
    try {
      const user = await this.fetchUserFromApi(id);
      if (user !== undefined) {
        this.cache.set(id, user);
      }
      return user;
    } catch (e) {
      if (e instanceof Error) {
        console.error(`Failed to fetch user ${id}: ${e.message}`);
      }
      return undefined;
    }
  }

  /**
   * Creates a new user.
   * @param userData The user data
   * @returns The created user
   */
  async createUser(userData: Omit<User, 'id' | 'createdAt'>): Promise<User> {
    const newUser: User = {
      ...userData,
      id: this.generateId(),
      createdAt: new Date(),
    };

    await this.saveUserToApi(newUser);
    this.cache.set(newUser.id, newUser);
    return newUser;
  }

  /**
   * Updates an existing user.
   * @param id The user ID
   * @param updates Partial user data to update
   * @returns The updated user
   */
  async updateUser(id: string, updates: Partial<User>): Promise<User> {
    const existingUser = await this.getUser(id);
    if (existingUser === undefined) {
      throw new Error(`User not found: ${id}`);
    }

    const updatedUser: User = {
      ...existingUser,
      ...updates,
      id, // Preserve ID
    };

    await this.saveUserToApi(updatedUser);
    this.cache.set(id, updatedUser);
    return updatedUser;
  }

  /**
   * Deletes a user.
   * @param id The user ID to delete
   * @returns True if deleted, false if not found
   */
  async deleteUser(id: string): Promise<boolean> {
    try {
      await this.deleteUserFromApi(id);
      this.cache.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  /**
   * Lists all active users.
   * @returns Array of active users
   */
  async getActiveUsers(): Promise<User[]> {
    const users = await this.getAllUsers();
    return users.filter(user => user.isActive);
  }

  /**
   * Fetches user from API with retry logic.
   */
  private async fetchUserFromApi(id: string): Promise<User | undefined> {
    let lastError: Error | undefined;

    for (let attempt = 0; attempt < this.maxRetries; attempt++) {
      try {
        const response = await fetch(`${this.apiUrl}/users/${id}`);
        if (!response.ok) {
          if (response.status === 404) {
            return undefined;
          }
          throw new Error(`HTTP ${response.status}`);
        }
        return await response.json() as User;
      } catch (e) {
        if (e instanceof Error) {
          lastError = e;
        }
        // Wait before retry
        await this.delay(Math.pow(2, attempt) * 100);
      }
    }

    throw lastError ?? new Error('Unknown error');
  }

  /**
   * Saves user to API.
   */
  private async saveUserToApi(user: User): Promise<void> {
    const response = await fetch(`${this.apiUrl}/users/${user.id}`, {
      method: 'PUT',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify(user),
    });

    if (!response.ok) {
      throw new Error(`Failed to save user: HTTP ${response.status}`);
    }
  }

  /**
   * Deletes user from API.
   */
  private async deleteUserFromApi(id: string): Promise<void> {
    const response = await fetch(`${this.apiUrl}/users/${id}`, {
      method: 'DELETE',
    });

    if (!response.ok) {
      throw new Error(`Failed to delete user: HTTP ${response.status}`);
    }
  }

  /**
   * Gets all users from API.
   */
  private async getAllUsers(): Promise<User[]> {
    const response = await fetch(`${this.apiUrl}/users`);
    if (!response.ok) {
      throw new Error(`Failed to fetch users: HTTP ${response.status}`);
    }
    return await response.json() as User[];
  }

  /**
   * Generates a unique ID.
   */
  private generateId(): string {
    return `user_${Date.now()}_${Math.random().toString(36).slice(2)}`;
  }

  /**
   * Delays execution.
   */
  private delay(ms: number): Promise<void> {
    return new Promise(resolve => {
      setTimeout(resolve, ms);
    });
  }
}
