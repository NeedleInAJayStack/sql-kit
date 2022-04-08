public final class SQLUnionBuilder: SQLQueryBuilder, SQLQueryFetcher {
    public var query: SQLExpression { self.union }

    public var union: SQLUnion
    public var database: SQLDatabase

    public init(on database: SQLDatabase, initialQuery: SQLSelect) {
        self.union = .init(initialQuery: initialQuery)
        self.database = database
    }

    public func union(distinct query: SQLSelect) -> Self {
       self.union.add(query, joiner: .init(type: .union))
       return self
    }

    public func union(all query: SQLSelect) -> Self {
       self.union.add(query, joiner: .init(type: .unionAll))
       return self
    }

    public func intersect(distinct query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .intersect))
       return self
    }

    public func intersect(all query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .intersectAll))
       return self
    }

    public func except(distinct query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .except))
       return self
    }

    public func except(all query: SQLSelect) -> Self {
        self.union.add(query, joiner: .init(type: .exceptAll))
       return self
    }
}

extension SQLDatabase {
    public func union(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self, initialQuery: predicate(.init(on: self)).select)
    }
}

extension SQLUnionBuilder {
    public func union(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.union(distinct: predicate(.init(on: self.database)).select)
    }

    public func union(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.union(all: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func union(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.union(distinct: predicate)
    }

    public func intersect(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.intersect(distinct: predicate(.init(on: self.database)).select)
    }

    public func intersect(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.intersect(all: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func intersect(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.intersect(distinct: predicate)
    }

    public func except(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.except(distinct: predicate(.init(on: self.database)).select)
    }

    public func except(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.except(all: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func except(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> Self {
        return self.except(distinct: predicate)
    }
}

// MARK: - Limit/offset

extension SQLUnionBuilder {
    /// Adds a `LIMIT` clause to the query. If called more than once, the last call wins.
    ///
    /// - Parameter max: Optional maximum limit. If `nil`, any existing limit is removed.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func limit(_ max: Int?) -> Self {
        self.union.limit = max
        return self
    }

    /// Adds a `OFFSET` clause to the query. If called more than once, the last call wins.
    ///
    /// - Parameter max: Optional offset. If `nil`, any existing offset is removed.
    /// - Returns: `self` for chaining.
    @discardableResult
    public func offset(_ n: Int?) -> Self {
        self.union.offset = n
        return self
    }
}

// MARK: - Order

extension SQLUnionBuilder {
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
        union.orderBy.append(expression)
        return self
    }
}

extension SQLSelectBuilder {
    public func union(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .union(distinct: predicate(.init(on: self.database)).select)
    }

    public func union(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .union(all: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func union(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .union(distinct: predicate(.init(on: self.database)).select)
    }

    public func intersect(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .intersect(distinct: predicate(.init(on: self.database)).select)
    }

    public func intersect(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .intersect(all: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func intersect(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .intersect(distinct: predicate(.init(on: self.database)).select)
    }

    public func except(distinct predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .except(distinct: predicate(.init(on: self.database)).select)
    }

    public func except(all predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .except(all: predicate(.init(on: self.database)).select)
    }

    /// Alias the `distinct` variant so it acts as the "default".
    public func except(_ predicate: (SQLSelectBuilder) -> SQLSelectBuilder) -> SQLUnionBuilder {
        return SQLUnionBuilder(on: self.database, initialQuery: self.select)
            .except(distinct: predicate(.init(on: self.database)).select)
    }
}
