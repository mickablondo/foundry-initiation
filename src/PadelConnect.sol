// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./IPadelConnect.sol";

/// @title Padel tournament management contract
/// @notice This contract makes it possible to manage padel tournaments and to connect the different users.
/// @dev The owner adds tournament managers.
///      The tournament managers create tournaments.
///      The players register for tournaments. 
/// @author Mickaël Blondeau
contract PadelConnect is IPadelConnect, Ownable {

    /// @notice Map of a manager address to his registration
    mapping(address => bool) public managers;

    /// @notice Map of a tournament id to a manager address
    mapping(uint => address) public linkManagerTournament;

    /// @notice Map of a manager to his tournament ids
    mapping(address => uint[]) linkTournamentsByManager;

    /// @notice Array of the tournaments
    Tournament[] public tournaments;

    /// @notice Map of a tournament id to the players registered
    mapping(uint => mapping(address => bool)) public playersRegistered;

    /// @notice Map of an address player to his registered tournaments
    mapping(address => uint[]) tournamentsByPlayer;

    /// @notice Map of a tournament id to the addresses of his followers
    mapping(uint => mapping(address => bool)) public followedTournaments;

    /// @notice Map of a tournamentId to the comments
    mapping(uint => mapping(uint => Comment)) public comments;

    /// @notice Map of a tournamentId to the max commentId
    /// @dev Use it to know the number of comments by tournament
    mapping(uint => uint) public idComments;

    /// @notice Map of a tournament to a map of a player address to the private comments
    mapping(uint => mapping(address => Comment[])) messages;

    /// @notice Map of a tournament to the players who have sent messages to the manager
    mapping(uint => address[]) exchanges;

    /// @notice Map of an address to a timestamp
    mapping(address => uint) lastPostDate;

    /// @notice Custom error when payment failed.
    error ErrorDuringPayment();

    /// @notice Custom error when the tournament is complete.
    error CompleteTournament();

    /// @notice Custom error when the registration phase is finished
    error RegistrationEnded();

    /**
     * @dev Sender must be a manager registered
     */
    modifier onlyManagers() {
        require(managers[msg.sender], "Forbidden");
        _;
    }

    /**
     * @dev Only the manager who has created the tournament can manage it.
     * @param _id the tournament id
     * @param _address address of the manager to check
     */
    modifier onlyTheManagerCreator(uint _id, address _address) {
        require(linkManagerTournament[_id] == _address, "Not the manager");
        _;
    }

    /**
     * @dev The id sent must exist.
     * @param _tournamentId id of the tournament
     */
    modifier shouldIdTournamentExists(uint _tournamentId) {
        require(_tournamentId < tournaments.length, "Wrong id sent");
        _;
    }

    /**
     * @dev The address must be not the zero address
     * @param _address the address to check
     */
    modifier notZeroAddress(address _address) {
         require(_address != address(0), "Cannot be the zero address");
         _;
    }

    /**
     * @dev The string must not be empty
     * @param _field the string to be checked
     */
    modifier notEmptyString(string memory _field) {
         require(bytes(_field).length > 0, "Cannot be empty");
         _;
    }

    /**
     * @dev Check the time between two comments
     * @param _address the address of the author
     */
    modifier waitUntilNewPost(address _address) {
        require(lastPostDate[msg.sender] < block.timestamp - 2, "Wait 2s");
        _;
    }

    /**
     * @dev See {IPadelConnect-addManager}.
     */
    function addManager(address _address) external onlyOwner notZeroAddress(_address) {
        require(!managers[_address], "Already registered");
        managers[_address] = true;
        emit ManagerAdded(_address);
    }

    /**
     * @dev See {IPadelConnect-addTournament}.
     */
    function addTournament(string calldata _city, uint _date, uint8 _diff,uint8 _maxPlayers) external onlyManagers notEmptyString(_city) {
        require(_date > block.timestamp, "Incorrect date");
        require(_maxPlayers > 0 && _maxPlayers % 2 == 0, "Played by 2");
        require(_diff <= uint(type(Difficulty).max), "Incorrect difficulty");

        uint id = tournaments.length;

        tournaments.push(
            Tournament(
                id,
                _city,
                _date,
                Difficulty(_diff),
                _maxPlayers,
                address(0),
                address(0)
            )
        );

        linkManagerTournament[id] = msg.sender;
        linkTournamentsByManager[msg.sender].push(id);
        emit TournamentCreated(id);
    }

    /**
     * @dev See {IPadelConnect-getTournaments}.
     */
    function getTournaments() external view onlyManagers returns(uint[] memory) {
        return linkTournamentsByManager[msg.sender];
    }

    /**
     * @dev See {IPadelConnect-registerPlayer}.
     */
    function registerPlayer(uint _id) external shouldIdTournamentExists(_id) {
        require(!playersRegistered[_id][msg.sender], "Already registered");
        Tournament memory tournament = tournaments[_id];

        if(tournament.date < block.timestamp) {
            revert RegistrationEnded();
        }

        if(tournament.registrationsAvailable == 0) {
            revert CompleteTournament();
        }

        playersRegistered[_id][msg.sender] = true;
        tournamentsByPlayer[msg.sender].push(_id);

        --tournament.registrationsAvailable;
        tournaments[_id].registrationsAvailable = tournament.registrationsAvailable;
    }

    /**
     * @dev See {IPadelConnect-getTournamentsByPlayer}.
     */
    function getTournamentsByPlayer() external view returns(uint[] memory) {
        return tournamentsByPlayer[msg.sender];
    }

    /**
     * @dev See {IPadelConnect-addWinners}.
     */
    function addWinners(uint _id, address _winner1, address _winner2) external shouldIdTournamentExists(_id) onlyTheManagerCreator(_id, msg.sender) notZeroAddress(_winner1) notZeroAddress(_winner2) {
        require(_winner1 != _winner2, "Same address");
        require(playersRegistered[_id][_winner1] && playersRegistered[_id][_winner2], "Not registered");

        tournaments[_id].winner1 = _winner1;
        tournaments[_id].winner2 = _winner2;
    }

    /**
     * @dev See {IPadelConnect-addComment}.
     */
    function addComment(uint _id, string calldata _message) external shouldIdTournamentExists(_id) notEmptyString(_message) waitUntilNewPost(msg.sender) {
        comments[_id][idComments[_id]] = Comment(_message, msg.sender);
        ++idComments[_id];
        lastPostDate[msg.sender] = block.timestamp;
        emit TournamentCommentAdded(_id);
    }

    /**
     * @dev See {IPadelConnect-shouldIdTournamentExists}.
     */
    function followTournament(uint _id, bool _follow) external shouldIdTournamentExists(_id) {
        followedTournaments[_id][msg.sender] = _follow;
        if(_follow) {
            emit TournamentFollowed(_id, msg.sender);
        }
    }

    /**
     * @dev See {IPadelConnect-addCommentToManager}.
     */
    function addMessageToManager(uint _id, string calldata _message) external shouldIdTournamentExists(_id) notEmptyString(_message) waitUntilNewPost(msg.sender) {
        messages[_id][msg.sender].push(Comment(_message, msg.sender));
        lastPostDate[msg.sender] = block.timestamp;
        // pour éviter les doublons
        if(messages[_id][msg.sender].length == 1) {
            exchanges[_id].push(msg.sender);
        }
    }

    /**
     * @dev See {IPadelConnect-getExchanges}.
     */
    function getExchanges(uint _id) external view returns(address[] memory) {
        return exchanges[_id];
    }

    /**
     * @dev See {IPadelConnect-addResponseToPlayer}.
     */
    function addResponseToPlayer(uint _id, address _player, string calldata _message) external shouldIdTournamentExists(_id) onlyTheManagerCreator(_id, msg.sender) notZeroAddress(_player) notEmptyString(_message) waitUntilNewPost(msg.sender) {
        messages[_id][_player].push(Comment(_message, msg.sender));
        lastPostDate[msg.sender] = block.timestamp;
    }

    /**
     * @dev See {IPadelConnect-getMessagesManagerPlayer}.
     */
    function getMessagesManagerPlayer(uint _id, address _player) external shouldIdTournamentExists(_id) notZeroAddress(_player) view returns(Comment[] memory) {
        return messages[_id][_player];
    }
}
