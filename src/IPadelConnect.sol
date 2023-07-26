// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title Padel tournament management contract
/// @notice This interface shows how to interact with the Smart Contract.
/// @author Mickaël Blondeau
interface IPadelConnect {

    /// @notice Enum of the differents diffulcties of the tournaments
    enum Difficulty {
        p25,
        p100,
        p250,
        p500,
        p1000,
        p2000
    }

    /// @notice Description of a tournament
    struct Tournament {
        uint id;
        string city;
        uint date;
        Difficulty difficulty;
        uint8 registrationsAvailable;
        address winner1;
        address winner2;
    }

    /// @notice Description of a Comment
    struct Comment {
        string message;
        address author;
    }

    /**
     * @dev Emitted when owner adds a new manager.
     */
    event ManagerAdded(address _address);

    /**
     * @dev Emitted when manager adds a new tournament.
     */
    event TournamentCreated(uint id);

    /**
     * @dev Emitted when somebody adds a new comment on a tournament forum.
     */
    event TournamentCommentAdded(uint tournamentId);

    /**
     * @dev Emitted when somebody follows a tournament.
     */
    event TournamentFollowed(uint tournamentId, address player);

    /**
     * @dev Add a new tournament manager with his informations.
     *
     * Requirements:
     * - `msg.sender` can only be the owner
     * - `_address` cannont be the zero address
     * - `_address` cannot be ever registering
     *
     * Emits a {ManagerAdded} event.
     *
     * @param _address address of the new manager 
     */
    function addManager(address _address) external;

    /**
     * @dev Add a new tournament.
     *
     * Requirements:
     * - `msg.sender` can only be a manager
     * - `_city` cannont be empty
     * - `_date` must be in the future
     * - `_maxPlayers` must be a multiple of two and greater than 0
     *
     * Emits a {TournamentCreated} event.
     *
     * @param _city city name of the new tournament 
     * @param _date date of the new tournament
     * @param _diff the difficulty of the tournament
     * @param _maxPlayers maximum number of players
     */
    function addTournament(string calldata _city, uint _date, uint8 _diff, uint8 _maxPlayers) external;

    /**
     * @dev Get the tournaments of the caller.
     *
     * @return array of the tournaments id managed by the caller
     */
    function getTournaments() external view returns(uint[] memory);

    /**
     * @dev Register a player to a tournament and pay the manager.
     *
     * Requirements:
     * - `_id` must be less than the length of the array
     * - date of the registration must be less than the start date of the tournament
     * 
     * @param _id id of the tournament
     */
    function registerPlayer(uint _id) external;

    /**
     * @dev Get the tournaments which the player is registered.
     * 
     * @return array of the tournaments id
     */
    function getTournamentsByPlayer() external view returns(uint[] memory);

    /**
     * @dev Add the two winners of the tournament and call the mint function to send them a NFT reward.
     *
     * Requirements:
     * - `msg.sender` can only be the owner
     * - `_id` must be less than the length of the array
     * - `_winner1` cannot be the zero address
     * - `_winner2` cannot be the zero address
     * - `_winner1` and `_winner2` cannot be the same addresses
     * 
     * @param _id id of the tournament
     * @param _winner1 the address of one of the winner
     * @param _winner1 the address of the other winner
     */
    function addWinners(uint _id, address _winner1, address _winner2) external;

    /**
     * @dev Add comment to the forum of a tournament.
     *
     * Requirements:
     * - `_id` must be less than the length of the array
     * - `_message` cannot be empty
     *
     * Emits a {TournamentCommentAdded} event.
     * 
     * @param _id id of the tournament which represents a subject of the forum
     * @param _message the message to add
     */
    function addComment(uint _id, string calldata _message) external;

    /**
     * @dev Follow the discussion of a tournament.
     *
     * Requirements:
     * - `_id` must be less than the length of the array
     * 
     * @param _id id of the tournament followed by msg.sender
     * @param _follow true if msg.sender wants to follow, else false
     */
    function followTournament(uint _id, bool _follow) external;

    /**
     * @dev Add comment to a manager of a tournament.
     *
     * Requirements:
     * - `_id` must be less than the length of the array
     * - `_message` cannot be empty
     *
     * Emits a {MessageAdded} event.
     * 
     * @param _id id of the tournament which represents a subject of the forum
     * @param _message the message to add
     */
    function addMessageToManager(uint _id, string calldata _message) external;

    /**
     * @dev Get the players who has sent messages to a manager.
     *
     * @param _id of the tournament
     * @return array of the addresses of the players
     */
    function getExchanges(uint _id) external view returns(address[] memory);

    /**
     * @dev Add response to a player of a tournament.
     *
     * Requirements:
     * - `_id` must be less than the length of the array
     * - `_player` cannot be the zero address
     * - `_message` cannot be empty
     * 
     * @param _id id of the tournament which represents a subject of the forum
     * @param _player address of the player
     * @param _message the message to add
     */
    function addResponseToPlayer(uint _id, address _player, string calldata _message) external;

    /**
     * @dev Get messages between a player and the manager of the tournament.
     *
     * Requirements:
     * - `_id` must be less than the length of the array
     * - `_player` cannot be the zero address
     * - `_message` cannot be empty
     * 
     * @param _id id of the tournament
     * @param _player address of the player
     * @return array of the comments
     */
    function getMessagesManagerPlayer(uint _id, address _player) external view returns(Comment[] memory);
}
