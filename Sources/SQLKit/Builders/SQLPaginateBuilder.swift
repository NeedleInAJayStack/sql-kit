
public protocol SQLPaginatableBuilder: AnyObject {
    /// Zero or more `ORDER BY` clauses.
    var orderBy: [SQLExpression] { get set }

    /// If set, limits the maximum number of results.
    var limit: Int? { get set }
    
    /// If set, offsets the results.
    var offset: Int? { get set }
}

// MARK: - Limit/offset

extension SQLPaginatableBuilder {
    /// Adds a `LIMIT` clause to the query. If called more than once, the last call wins.
    ///
    /// - Parameter max: Optional maximum limit. If `nil`, any existing limit is removed.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func limit(_ max: Int?) -> Self {
        self.limit = max
        return self
    }

    /// Adds a `OFFSET` clause to the query. If called more than once, the last call wins.
    ///
    /// - Parameter max: Optional offset. If `nil`, any existing offset is removed.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func offset(_ n: Int?) -> Self {
        self.offset = n
        return self
    }
}

// MARK: - Order

extension SQLPaginatableBuilder {
    /// Adds an `ORDER BY` clause to the query with the specified column and ordering.
    ///
    /// - Parameters:
    ///   - column: Name of column to sort results by. Appended to any previously added orderings.
    ///   - direction: The sort direction for the column.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orderBy(_ column: String, _ direction: SQLDirection = .ascending) -> Self {
        return self.orderBy(SQLColumn(column), direction)
    }


    /// Adds an `ORDER BY` clause to the query with the specifed expression and ordering.
    ///
    /// - Parameters:
    ///   - expression: Expression to sort results by. Appended to any previously added orderings.
    ///   - direction: An expression describing the sort direction for the ordering expression.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orderBy(_ expression: SQLExpression, _ direction: SQLExpression) -> Self {
        return self.orderBy(SQLOrderBy(expression: expression, direction: direction))
    }

    /// Adds an `ORDER BY` clause to the query using the specified expression.
    ///
    /// - Parameter expression: Expression to sort results by. Appended to any previously added orderings.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func orderBy(_ expression: SQLExpression) -> Self {
        orderBy.append(expression)
        return self
    }
}
